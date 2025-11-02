{ config, pkgs, ... }:
#this is org mode tangle
{

  home.username = "andrew";
  home.homeDirectory = "/home/andrew";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = with pkgs; [

    #dependencies
    fd
    ripgrep
    semgrep
    cmake
    gcc
    llvm
    fzf
    age
    sops
    gnumake
    openvpn
    gh
    nh

    #fonts and icons
    bibata-cursors
    hicolor-icon-theme
    adwaita-icon-theme
    adwaita-qt
    adwaita-fonts
    nerd-fonts.fira-code
    nerdfix


    #social
    telegram-desktop
    discord

    #zsh-related
    starship
    fastfetch


    #hyprland stuff
    rofi
    rofi-network-manager
    rofi-file-browser
    libnma-gtk4
    wttrbar
    wlogout
    swaylock
    swayidle
    nwg-look
    hyprshot
    wl-clipboard
    cliphist
    waypaper
    xfce.thunar
    btop



    obsidian
    obs-studio
    qbittorrent
    resilio-sync

    floorp-bin

    #video plugins
    mpv
    ffmpeg
    yt-dlp
    syncplay


    #python
    #(python314.withPackages (ppkgs: [
    #ppkgs.numpy
    #ppkgs.requests
    #ppkgs.pandas
    #ppkgs.polars
    #]))

    ];

qt = {
  enable = true;
  platformTheme.name = "qt6ct";
};

gtk = {
  enable = true;
  iconTheme = {
    name = "Adwaita-dark";
  };
};

home.sessionVariables = {
    EDITOR = "emacs";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

   programs.waybar.enable = true;
   programs.emacs.extraPackages = epkgs: with epkgs; [
    vterm
  ];


  # Let Home Manager install and manage itself.
   programs.home-manager.enable = true;
} #final bracket for home.nix!
