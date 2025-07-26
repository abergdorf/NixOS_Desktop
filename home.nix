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
    wttrbar
    #waybar
    waypaper
    xfce.thunar
    kdePackages.ark
    kdePackages.dolphin

    obsidian
    obs-studio
    qbittorrent

    floorp

    #video plugins
    mpv
    ffmpeg
    #madvr #maybe not needed?

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

home.sessionVariables = {
    EDITOR = "emacs";
  };

   programs.waybar.enable = true;
   programs.emacs.extraPackages = epkgs: with epkgs; [
    vterm
  ];



  # Let Home Manager install and manage itself.
   programs.home-manager.enable = true;
} #final bracket for home.nix!
