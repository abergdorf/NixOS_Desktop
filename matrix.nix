{ config, pkgs, lib, ... }:

let
  # Replace these with your actual details
  domain = "cellochem.vip";
  matrixSubdomain = "matrix.${domain}";

  clientConfig = {
    "m.homeserver".base_url = "https://${matrixSubdomain}";
    "m.identity_server" = {};
  };

  serverConfig = {
    "m.server" = "${matrixSubdomain}:443";
  };

  mkWellKnown = data: ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON data}';
  '';
in {

  #SOPS
  sops.secrets.turnSecret = {
    owner = "turnserver";
  };
  # Create a templated YAML file for Synapse behind the scenes
  sops.templates."synapse_turn.yaml".content = ''
    turn_shared_secret: "${config.sops.placeholder.turnSecret}"
  '';

  # Ensure Synapse has permission to read the templated file
  sops.templates."synapse_turn.yaml".owner = "matrix-synapse";

  # 1. Open the necessary firewall ports
  #networking.firewall.allowedTCPPorts = [ 80 443 8448 ];

  # 2. Configure the Matrix Synapse Service
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domain;
      public_baseurl = "https://${matrixSubdomain}";

      # Use PostgreSQL instead of SQLite for much better performance
      database = {
        name = "psycopg2";
        allow_unsafe_locale = true;
        args = {
          user = "matrix-synapse";
          database = "matrix-synapse";
          host = "/run/postgresql";
        };
      };

      # Listen locally so Nginx can proxy traffic to it
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "127.0.0.1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = true;
            }
          ];
        }
      ];

      extraConfigFiles = [ config.sops.templates."synapse_turn.yaml".path ];


      max_upload_size_mib = 100;
      url_preview_enabled = true;
      enable_registration = false;
      enable_metrics = false;
      media_retention = {
        local_media_lifetime = null; #doesn't remove friend's media from my server
        remote_media_lifetime = "14d"; #removes federated trash every 2 weeks
      };
      # --- TURN Server Settings for Calls ---
      turn_uris = [
        "turn:turn.cellochem.vip:3478?transport=udp"
        "turn:turn.cellochem.vip:3478?transport=tcp"
      ];
      turn_shared_secret = config.sops.secrets.turnSecret.path;
      turn_user_lifetime = "1h";
      turn_allow_guests = true;
      #--
      registration_shared_secret_path = "/var/lib/matrix-synapse/registration_secret";
      trusted_key_servers = [
        {
          server_name = "matrix.org";
        }
      ];
    };
  };

  # 3. Automatically provision PostgreSQL for Synapse
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [{
      name = "matrix-synapse";
      ensureDBOwnership = true;
    }];
  };

  # 4. Nginx Reverse Proxy & Matrix Delegation
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    appendHttpConfig = ''
      proxy_headers_hash_max_size 512;
      proxy_headers_hash_bucket_size 64;
    '';

    virtualHosts = {
      # The base domain tells other servers where your Matrix instance actually lives
      "${domain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        root = "/var/www/cellochem";

        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;

        # Fixed: This now correctly points to the client endpoint
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };

      # The subdomain acts as the actual proxy passing traffic to Synapse
      "${matrixSubdomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8008";
          extraConfig = ''
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header Host $host;
                client_max_body_size 100M;
          '';
        };
      };
    };
  };
 # 6. Cloudflare Tunnel (Bypass ISP Firewall)
  services.cloudflared = {
    enable = true;
    tunnels."matrix-tunnel" = {
      credentialsFile = "/var/lib/cloudflared/tunnel.json";
      default = "http_status:404";
      ingress = {
        # Route both domains directly to Nginx's secure port
        "cellochem.vip" = {
          service = "https://127.0.0.1:443";
          originRequest.noTLSVerify = true; # Trusts your local Let's Encrypt certs
          #originServerName = "cellochem.vip";
        };
        "matrix.cellochem.vip" = {
          service = "https://127.0.0.1:443";
          originRequest.noTLSVerify = true;
          #originServerName = "matrix.cellochem.vip";
        };
      };
    };
  };
 # Explicitly define the Cloudflared user so it can own its credentials
  users.users.cloudflared = {
    group = "cloudflared";
    isSystemUser = true;
  };
  users.groups.cloudflared = {};

  #coturn
  # --- Coturn (STUN/TURN for Audio/Video Calls) ---
  services.coturn = {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;

    # The domain Element will look for
    realm = "turn.cellochem.vip";

    # Listen on all local network interfaces
    listening-ips = [ "0.0.0.0" ];

    # Generate a strong, random password here!
    use-auth-secret = true;
    static-auth-secret = config.sops.secrets.turnSecret.path;

    # The ephemeral UDP port range for actual video relay
    min-port = 49000;
    max-port = 50000;

    extraConfig = ''
      external-ip=136.32.190.0/192.168.1.125
    '';
  };

  # Open the NixOS firewall for the TURN matchmaking port and the video relay ports
  networking.firewall.allowedTCPPorts = [ 80 443 8448 3478 5349 ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 49000; to = 50000; }
  ];
}
