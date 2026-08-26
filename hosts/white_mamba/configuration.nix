{ config, pkgs, ... }:

#org-mode tangled haha
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./filesystems.nix
    ];
  nix = {
    settings = {
     auto-optimise-store = true;
     experimental-features = ["nix-command"
				"flakes"];
  };
};
   # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

programs.niri.enable = true;
services.greetd = {
	enable = true;
	settings = {
	  default_session = { command = "${config.programs.niri.package}/bin/niri-session";
		user = "nixandrew";
		};
	};
 };
programs.noctalia.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users."andrew" = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  users.users."nixandrew" = {
    isNormalUser = true;
    uid = 1001;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    dejavu_fonts
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    niri
    emacs-pgtk
    polkit
    polkit_gnome
    gnome-keyring
    alacritty
    ghostty
    fuzzel
    fzf
    home-manager
    firefox
    fd
    ripgrep
    symbola
    bibata-cursors
    unzip
    p7zip
    zsh
    oh-my-zsh
    fastfetch
    gparted
    openssh
    seahorse
    gcc
    cmake
    python3
    xwayland-satellite
    starship


  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

# List services that you want to enable:
services.emacs = {
  enable = true;
};

services.resilio.enable = true;

services.libinput.enable = true;

programs.steam = {
  enable = true;
  remotePlay.openFirewall= true;

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

nix.gc = {  #garbage-collect nix-store
automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    };

   # Allow unfree packages


  #Enable polkit (policy kit)
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

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
  settings.Manager = {
     DefaultTimeoutStopSec=10;
   };
};


  # Enable CUPS to print documents.
  services.printing.enable = true;

system.stateVersion = "26.05"; # Did you read the comment?

}
