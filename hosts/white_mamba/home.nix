{ config, pkgs, ... }:
{

  home.username = "nixandrew";
  home.homeDirectory = "/home/nixandrew";

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
    openssl
    nh
    pv
    direnv

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
    (element-desktop.override {
      commandLineArgs = "--password-store=gnome-libsecret";})

    #zsh-related
    starship
    fastfetch
    killall



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
    thunar
    btop



    obsidian
    obs-studio
    qbittorrent
    resilio-sync
    tauon
    steam

    floorp-bin

    #video plugins
    mpv
    ffmpeg
    yt-dlp
    syncplay

(pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      ggplot2
      plotly
      tidyverse
      languageserver
      lintr
      roxygen2
      collections
      rmarkdown
      shiny
      shinydashboard
      shinythemes
      stringi
      stringr
      xml2
      dplyr
      xts
      DT
      packrat
      rsconnect
      PKI
      openssl
      golem
      enviPat
    ];
  })
    (pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      ggplot2
      plotly
      tidyverse
      languageserver
      lintr
      roxygen2
      collections
      rmarkdown
      shiny
      shinydashboard
      shinythemes
      stringi
      stringr
      xml2
      dplyr
      xts
      DT
      packrat
      rsconnect
      PKI
      openssl
      golem
      enviPat
    ];
  })
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

   programs.emacs.extraPackages = epkgs: with epkgs; [
    vterm
  ];


   programs.vesktop= {
    enable = true;
    vencord.settings = {
  autoUpdate = true;
  autoUpdateNotification = false;
  disableMinSize = true;
  notifyAboutUpdates = false;
  plugins = {
    FakeNitro = {
      enabled = true;
    };
    MessageLogger = {
      enabled = true;
      ignoreSelf = true;
    };
  };
  useQuickCss = true;
    };
   };

  # Let Home Manager install and manage itself.
   programs.home-manager.enable = true;

home.stateVersion = "26.11"; # Please read the comment before changing.

} #end of home.nix!
