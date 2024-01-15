{ config, pkgs, ... }: {

  # Nix settings, auto cleanup and enable flakes
  nix = {
    package = pkgs.nixFlakes;
    settings.auto-optimise-store = true;
    # settings.allowed-users = [ "bernd" ];
    settings.trusted-users = [ "@wheel" "root" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      builders-use-substitutes = true
    '';
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # NixOS uses NTFS-3G for NTFS support.
  boot.supportedFilesystems = [ "ntfs" ];

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    networkmanager.enable = true;
    # firewall = {
    #   enable = true;
    #   allowedTCPPorts = [ 80 443 8080 5000 ];
    # };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable sound.
  sound.enable = true;
  hardware = {
    opengl.enable = true;
    trackpoint = {
      enable = true;
      sensitivity = 255;
    };
    bluetooth.enable = true;
  };

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  # pipewire setup
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  # List services that you want to enable:
  services = {
    logind.killUserProcesses = true;
    gnome.gnome-keyring.enable = true;
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      # settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "yes";
      openFirewall = true;
    };
    # enable blueman
    blueman.enable = true;
    # Enable CUPS to print documents.
    printing.enable = true;
    avahi.enable = true;
    # avahi.nssmdns4 = true;
    avahi.nssmdns = true;
    # for a WiFi printer
    avahi.openFirewall = true;
  };

  security.polkit.enable = true;

  # fonts
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "DroidSansMono"
          "Hack"
          # "Iosevka"
        ];
      })
      fira-code
      fira-code-symbols
      terminus_font
      jetbrains-mono
      powerline-fonts
      gelasio
      # nerdfonts
      iosevka
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-code-pro
      ttf_bitstream_vera
      terminus_font_ttf
    ];
  };

  # Configure xserver
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    layout = "de";
    xkbVariant = "";
    #xkbOptions = "ctrl:nocaps";
    # libinput = {
    #   enable = true;
    #   mouse = {
    #     accelProfile = "flat";
    #     accelSpeed = "0";
    #     middleEmulation = false;
    #   };
    #   touchpad = {
    #     accelProfile = "flat";
    #     accelSpeed = "0.5";
    #     naturalScrolling = true;
    #   };
    # };
  };

  environment.systemPackages = with pkgs; [
    xorg.xhost
    # gtk
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    playerctl
    xfce.thunar
    xfce.thunar-volman
    #
    gnupg
    pam_gnupg
    # nix
    nixpkgs-lint
    nixpkgs-fmt
    nixfmt
  ];

  # programs
  # thunar settings
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];

  };
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  #
  programs.dconf.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.zsh.enable = true;

  programs.light.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # vm user
  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
