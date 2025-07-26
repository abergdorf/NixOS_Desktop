{inputs, config, pkgs, ... }:
#org-mode tangled
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./filesystem.nix
    ];

   nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        ];
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
#gc = {  #garbage-collect nix-store
#automatic = true;
    #dates = "weekly";
    #options = "--delete-older-than 7d";
    #};
};
   # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  #Enable polkit (policy kit)
  security.polkit.enable = true;

systemd = {
  user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };
   extraConfig = ''
     DefaultTimeoutStopSec=10s
   '';
};


  # Enable CUPS to print documents.
  services.printing.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  #openSSH

   services.openssh = {

     enable = true;
     settings.PasswordAuthentication = false;
   };

   # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn];

  programs.nm-applet.enable = true;

  #Keyring for wifi password
  services.gnome.gnome-keyring.enable = true;
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";

  #to get pia to work, need to open the .ovpn file and change compress to comp-lzo no and completely remove <crl-verify> .... </crl-verify>
  services.pia = {
  enable = true;
  authUserPassFile = config.sops.defaultSopsFile;
};


  #programs.openvpn.enable = true;

# Inside configuration.nix, at the top level with other options like networking, services, etc.
sops = {
  defaultSopsFile = ./secrets/secrets.yaml; # Path relative to configuration.nix
  defaultSopsFormat = "yaml"; # Or json, dotenv, etc.
  age.keyFile = "/home/andrew/.config/sops/age/keys.txt";

  # Define each secret you want to make available to the system.
  # The key names here must match the keys in your secrets.yaml.
  secrets = {
    "wifiPassword" = { # This matches "wifiPassword" in your secrets/secrets.yaml
      # Optional: You can specify owner, group, and mode for the decrypted file
      owner = "root";
      group = "networkmanager";
      mode = "0400";
      # e.g., owner = "root"; group = "networkmanager"; mode = "0400";
      # Consider 'neededForUsers = true;' if a non-root user or service needs it
      # (e.g., NetworkManager might need to read it if you configure wifi directly).
    };
    "authUserPass" = {
      owner = "andrew";
      mode = "0400";
      neededForUsers = true;
    };
  };

  # Optional: You can also define templates to combine multiple secrets into one file.
  # templates."my_app.env" = {
  #   content = ''
  #     MY_API_KEY="${config.sops.placeholder.myApiKey}"
  #   '';
  #   owner = "myuser";
  #   mode = "0400";
  # };
};

# Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

# Enable the X11 windowing system.
  services.xserver.enable = true;

  # # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

   # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

# Define user groups
  users.groups.plexusers = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrew = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" "plexusers"];
    packages = with pkgs; [
    #  kate
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  users.users.plex = {
    isSystemUser = true; # Plex usually runs as a system user
    group = "plexusers";
    #extraGroups = [ "plexusers" ]; # Add "plexusers" here
    # Other Plex user properties might be managed by the Plex module
  };

#  system.activationScripts.setMediaPermissions = ''
#   echo "Setting permissions for /media for Plex and users..."
#
#    # Ensure /media is actually mounted before attempting to change permissions
#    if ! mountpoint -q /media; then
#      echo "/media is not mounted, skipping permission setup." >&2
#      exit 0 # Exit successfully, as the drive might be absent (e.g., external)
#    fi
#
#    # Use absolute paths to coreutils and findutils binaries provided by Nixpkgs
#    ${pkgs.coreutils}/bin/chown -R andrew:plexusers /media
#    ${pkgs.findutils}/bin/find /media -type d -exec ${pkgs.coreutils}/bin/chmod 775 {} \;
#    ${pkgs.findutils}/bin/find /media -type f -exec ${pkgs.coreutils}/bin/chmod 664 {} \;
#  '';
#

environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    emacs
    git
    cmake
    gcc
    kitty
    ghostty
    zsh
    home-manager
    gparted
    openssh
    seahorse
    polkit
    polkit_gnome

    waybar #some weirdness about having it in home-manager
    inputs.zen-browser.packages."${system}".specific
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
services.emacs = {
  enable = true;
};

#plex
  services.plex = {
   enable = true;
   openFirewall = true;

  };

programs.zsh = {
   enable = true;
   enableCompletion = true;
   ohMyZsh = {
     enable = true;
     plugins = ["git"];
     theme = "agnoster";
   };
   autosuggestions.enable = true;
   syntaxHighlighting.enable = true;
};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Did you read the comment?

}#End of configuration.nix!
