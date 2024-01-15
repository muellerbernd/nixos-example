{ config, lib, pkgs, inputs, ... }:
{
  home = {
    username = "bernd";
    homeDirectory = "/home/bernd";
    packages = with pkgs; [
      procps
      # editors
      neovim
      #neovim-remote
      vim
      # git
      git
      git-lfs
      lazygit
      vcstool
      yarn
      nodejs
      # terminal
      glow
      alacritty
      wezterm
      antigen
      starship
      tmux
      zoxide
      # better shell history
      w3m
      atuin
      ranger
      ueberzugpp
      mupdf
      poppler_utils
      exiftool
      bat
      trash-cli
      yazi
      ffmpegthumbnailer
      unar
      jq
      joshuto
      imgcat
      timg
      chafa
      libsixel
      neofetch
      fzf
      fd
      ripgrep
      file
      ripgrep-all
      # notifications
      dunst
      libnotify
      # images
      feh
      gimp
      graphicsmagick
      inkscape
      # pdf
      zathura
      okular
      pdfarranger
      # tools
      stow
      networkmanagerapplet
      xdotool
      # security
      keepassxc
      gnome.gnome-keyring
      gnome.seahorse
      gnome.adwaita-icon-theme
      lxde.lxsession
      gnupg
      # bluetooth
      blueman
      # apps
      gnome.simple-scan
      xclip
      redshift
      gparted
      filezilla
      libreoffice
      vlc
      nextcloud-client
      pavucontrol
      xfce.thunar
      xfce.thunar-volman
      gnome.file-roller
      archiver
      xfce.xfce4-screenshooter
      grimblast
      flameshot
      obs-studio
      grim
      ntfs3g
      gvfs
      blender
      prusa-slicer
      # cli helpers
      usbutils
      man
      tealdeer
      # cli
      pandoc
      haskellPackages.pandoc-crossref
      curl
      wget
      light
      lm_sensors
      htop
      bottom
      dmidecode
      unzip
      arandr
      scrot
      ffmpeg
      killall
      acpi
      ctags
      ncdu
      lsd
      bc
      # env
      direnv
      # programming
      ghc
      gnumake
      cmake
      gcc
      gdb
      rustup
      python311Full
      go
      icecream
      icemon
      # formatter
      yamlfmt
      stylua
      black
      isort
      clang-tools
      nodePackages.prettier
      beautysh
      libxml2 # for xmllint
      # lsp
      ccls
      python311Packages.python-lsp-server
      python311Packages.python-lsp-black
      python311Packages.pylsp-rope
      python311Packages.pyls-flake8
      nodePackages.pyright
      # rnix-lsp
      nil
      sumneko-lua-language-server
      marksman
      cmake-language-server
      texlab
      nodePackages_latest.vscode-langservers-extracted
      nodePackages_latest.bash-language-server
      gopls
      # rust-analyzer
      # haskell
      haskellPackages.haskell-language-server
      # python packages
      pkgs.python311Packages.flask
      pkgs.python311Packages.requests
      pkgs.python311Packages.pygments
      pkgs.python311Packages.numpy
      # latex
      texlive.combined.scheme-full
      # texlive.combined.scheme-medium
      # browsers
      chromium
      firefox
      # media
      spotify
      # messenger
      gajim
      teams-for-linux
      # matrix client
      cinny-desktop
      #
      thunderbird
      # vpn
      openconnect_openssl
      networkmanager-openconnect
      wireshark
      # mesh and pointcloud
      meshlab
      cloudcompare
      # custom packages
      annotator

      # theming
      lxqt.lxqt-qtplugin
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
      xdg-desktop-portal
      papirus-icon-theme
    ];
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.firefox = {
    enable = true;

    # Privacy about:config settings
    profiles.default = {
      id = 0;
      name = "Bernd Müller";

      # userChome.css to make it look better
      userChrome =
        "\n      /* hides the native tabs */\n#TabsToolbar {\n  visibility: collapse;\n}\n\n                ";
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        "extensions.autoDisableScopes" = 0;

        "browser.search.defaultenginename" = "Google";
        "browser.search.selectedEngine" = "Google";
        "browser.urlbar.placeholderName" = "Google";
        "browser.search.region" = "US";

        "browser.uidensity" = 1;
        "browser.search.openintab" = true;
        "xpinstall.signatures.required" = false;
        "extensions.update.enabled" = false;

        "browser.display.use_document_fonts" = true;
        "pdfjs.disabled" = true;
        "media.videocontrols.picture-in-picture.enabled" = true;
      };
    };
  };

  gtk = {
    enable = true;
    font.name = "Cantarell 10";
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    GTK_USE_PORTAL = 1;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "kvantum";
  };

  xdg = {
    enable = true;
    configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
      General.theme = "Adwaita-dark";
    };
  };
  # not so fancy pointer
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  # fancy pointer
  # home.pointerCursor =
  #   let
  #     getFrom = url: hash: name: {
  #       gtk.enable = true;
  #       x11.enable = true;
  #       name = name;
  #       size = 48;
  #       package =
  #         pkgs.runCommand "moveUp" { } ''
  #           mkdir -p $out/share/icons
  #           ln -s ${pkgs.fetchzip {
  #             url = url;
  #             hash = hash;
  #           }} $out/share/icons/${name}
  #         '';
  #     };
  #   in
  #   getFrom
  #     "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Pop.tar.gz"
  #     "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk="
  #     "Fuchsia-Pop";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
# vim: set ts=2 sw=2:

