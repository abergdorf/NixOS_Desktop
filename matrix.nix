{ config, pkgs, lib, ... }:

let
  # Replace these with your actual details
  domain = "cellochem.vip";
  matrixSubdomain = "matrix.${domain}";

  clientConfig = {
    "m.homeserver".base_url = "https://${matrixSubdomain}";
    "m.identity_server" = {};
    "org.matrix.msc4143.rtc_foci" = [
      {
        type = "livekit";
        livekit_service_url = "https://${matrixSubdomain}/livekit/jwt";
      }
    ];
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
  sops.secrets.livekit_key = {
    mode = "0444";
  };
  sops.secrets.telegram_env = {
    owner = "mautrix-telegram";
  };


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

      #extraConfigFiles = [ config.sops.templates."synapse_turn.yaml".path ];

      app_service_config_files = [
        "/var/lib/mautrix-telegram/telegram-registration.yaml"
      ];

      # --- Enable Modern LiveKit/Element Call ---
      experimental_features = {
        msc3266_enabled = true;
        msc4140_enabled = true;
        msc4222_enabled = true;
      };

      max_upload_size_mib = 100;
      url_preview_enabled = true;
      enable_registration = false;
      enable_metrics = false;
      media_retention = {
        local_media_lifetime = null; #doesn't remove friend's media from my server
        remote_media_lifetime = "14d"; #removes federated trash every 2 weeks
      };

     registration_shared_secret_path = "/var/lib/matrix-synapse/registration_secret";
      trusted_key_servers = [
        {
          server_name = "matrix.org";
        }
      ];#listeners
    };#settings
  };#matrix-synapse

  # 3. Automatically provision PostgreSQL for Synapse
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" "mautrix-telegram" ];
    ensureUsers = [
      { name = "matrix-synapse"; ensureDBOwnership = true; }
      { name = "mautrix-telegram"; ensureDBOwnership = true; }
      ];
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
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };

      # The subdomain acts as the actual proxy passing traffic to Synapse and LiveKit
      "${matrixSubdomain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        # --- NEW: Route authorization requests to the JWT bridge (Port 8080) ---
        locations."^~ /livekit/jwt/" = {
          proxyPass = "http://127.0.0.1:8080/";
        };

        # --- NEW: Route active video streams to the LiveKit SFU (Port 7880) ---
        locations."^~ /livekit/sfu/" = {
          proxyPass = "http://127.0.0.1:7880/";
          proxyWebsockets = true; # Crucial for LiveKit!
        };

        # --- EXISTING: The Catch-All for standard Synapse chat traffic ---
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

  # --- The LiveKit SFU (Video Server) ---
  services.livekit = {
    enable = true;
    keyFile = config.sops.secrets.livekit_key.path;
    settings = {
      port = 7880; # Internal websocket port
      room.auto_create = false;
      rtc = {
        # Force LiveKit to use your home's actual public IP for video routing
        node_ip = "136.32.190.0";
        port_range_start = 50000;
        port_range_end = 50050;
      };
    };
  };

  # Open the NixOS firewall strictly for the LiveKit UDP video ports
  networking.firewall.allowedUDPPortRanges = [
    { from = 50000; to = 50050; }
  ];

  # --- The Matrix JWT Bridge ---
  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://${matrixSubdomain}/livekit/sfu";
    keyFile = config.sops.secrets.livekit_key.path;
  };

  # Allow your users to create video rooms
  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "cellochem.vip";


services.mautrix-telegram = {
    enable = true;
    environmentFile = config.sops.secrets.telegram_env.path;
    settings = {
      homeserver = {
        address = "http://127.0.0.1:8008";
        domain = domain;
      };
      appservice = {
        address = "http://127.0.0.1:8081"; # Avoids conflict with LiveKit JWT
        hostname = "127.0.0.1";
        port = 8081;
        database = "postgresql:///mautrix-telegram?host=/run/postgresql";
        id = "telegram";
        bot_avatar = "mxc://maunium.net/tJCRmUyJDsgRNgqhOgoiHWbX";
      };
      bridge = {
        relay_user_distinguishers = [];
        permissions = {
          # Grant only your specific user admin access to the bridge
          "@andrew:${domain}" = "admin";
        };
      };
    };
  };

}
