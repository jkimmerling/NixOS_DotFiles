# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    overlays = [
      (self: super: {
        fcitx-engines = pkgs.fcitx5;
      })
    ];
  };

  # Bootloader.
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/nvme0n1";
        useOSProber = true;
      };
    };
  };

  # Enable networking
  networking = {
    firewall = {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ]; 
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };
    hostName = "nixos";
    networkmanager = {
      enable = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Rainy_River";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };


  # Enable sound.
  sound.enable = true;

  # Audio and Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
    };
    pulseaudio = {
      enable = true;
    };
  };

  # GFX
  hardware = {
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia.prime = {
    offload.enable = true;
    # sync.enable = true;
    # Bus ID of the Intel GPU. You can find it using lspci, either unde>
    intelBusId = "PCI:0:2:0";
    # Bus ID of the NVIDIA GPU. You can find it using lspci, either und>
    nvidiaBusId = "PCI:1:0:0";
    };
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraGroups.vboxusers.members = [ "jasonk" ];
    users.jasonk = {
      isNormalUser = true;
      description = "jasonk";
      extraGroups = [ "networkmanager" "wheel" "docker" "mpd"];
      packages = with pkgs; [
        firefox
        kate
        git
        dconf
        brave
      ];
    };
  };

  programs.dconf.enable = true;

  home-manager.users.jasonk = { pkgs, ... }: {
    home.username = "jasonk";
    home.stateVersion = "23.05";
    home.homeDirectory = "/home/jasonk";

    nixpkgs.config.allowUnfree = true;

    xsession.numlock.enable = true;

    home.packages = with pkgs; [ 
      #Misc
      appimage-run
      picom
      mono
      qbittorrent
      vmware-workstation
      libsForQt5.kdeconnect-kde
      gnome.gnome-calendar
      gnome-online-accounts
      gnome.gnome-keyring
      steam-run
      ventoy-full

      #Documentation
      libreoffice
      okular
      mcomix3
      anytype
      marktext
      calibre

      # Media
      flameshot
      vlc
      spotify
      downonspot
      musikcube
      puddletag
      picard
      obs-studio
      cava
      yt-dlp

      #Gaming
      lutris
      steam
      wineWowPackages.staging
      winetricks
      mesa
      glxinfo

      #Networking
      networkmanagerapplet
      netcat-gnu
      lsof

      #Hardware
      pciutils
      acpi
      lm_sensors
      tlp
      brightnessctl
      thinkfan
      psensor

      #System info
      glances
      neofetch

      #Printing
      hplip #Driver for HP printer
      system-config-printer #GUI for printing
      imagemagick

      #Chat / Community
      discord
      slack
      teamspeak_client
      skypeforlinux

      #Sound
      pavucontrol

      #Launchers and Menus
      rofi
      ulauncher

      #Remote Access
      remmina

      #Graphics
      gimp
      feh
      freecad
      blender
      xfce.ristretto
      qrencode
      inkscape

      #Archiving
      zip
      xarchiver
      unzip

      #development
      vscode
      jetbrains.idea-community
      jetbrains.pycharm-community
      direnv
      # postman
      mysql-workbench
      redisinsight
      pgadmin4

      #Virtualization
      docker-compose
      virt-manager

      #File manager related
      xfce.exo
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.tumbler
      gvfs
      xfce.xfconf # thunar save settings
      xorg.xrandr 
      
      #Terminals and Shell
      alacritty
      kitty
      fish
      
    ];

    gtk = {
      enable = true;
      font.name = "Droid Sans Mono 18";
      theme = {
        name = "gruvbox-dark";
        package = pkgs.gruvbox-dark-gtk;
      };
    };    

    programs.kitty = {
      enable = true;
      settings = {
        remember_window_size = "no";
        initial_window_width = "180c";
        initial_window_height = "60c";
        font_size = "20.0";
      };
    };

    programs.bash ={
      enable = true;
      shellAliases = {
        "yt-dlp-playlist" = "yt-dlp --extract-audio --audio-format mp3 -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' --sleep-interval 30"; 
        "yt-dlp-single" = "yt-dlp --extract-audio --audio-format mp3 -o '%(title)s.%(ext)s'";
        "ssh-postgres" = "ssh -i .ssh/aws-extraction.pem jasonk@3.129.29.145";
        "ssh-extraction" = "ssh -i .ssh/aws-extraction.pem jasonk@18.190.117.252";
        "ssh-redis" = "ssh -i .ssh/aws-extraction.pem jasonk@18.190.131.227";
        "ssh-api" = "ssh -i .ssh/aws-extraction.pem jasonk@164.90.154.123";
      };
      initExtra =
      ''
        init-python-airflow () {
          cp ~/NixOS_DotFiles/nix-shells/python/airflow/shell.nix ./
          nix-shell
        }
        init-python-notebook () {
          cp ~/NixOS_DotFiles/nix-shells/python/notebook/shell.nix ./
          nix-shell
        }
        init-elixir () {
          cp ~/NixOS_DotFiles/nix-shells/elixir/shell.nix ./
          nix-shell
        }
        init-phoenix () {
          cp ~/NixOS_DotFiles/nix-shells/phoenix/shell.nix ./
          nix-shell
        }
        init-livebook () {
          cp ~/NixOS_DotFiles/nix-shells/livebook/shell.nix ./
          nix-shell
        }
        init-java () {
          cp ~/NixOS_DotFiles/nix-shells/java/shell.nix ./
          nix-shell
        }  
        init-rust () {
          cp ~/NixOS_DotFiles/nix-shells/rust/shell.nix ./
          nix-shell
        }

        function convert-iphone-pics() {
          cd /home/jasonk/Downloads/iPhone
          for f in *.heic; do magick $f -quality 95 $f.jpg;done
          rm /home/jasonk/Downloads/iPhone/*.heic
        }  

        function code-extraction() {
          cd /home/jasonk/Development/Elixir/Projects/extraction
          nix-shell
          code .
        }  


      '';
    };

    programs.rofi = {
      enable = true;
      theme = "Monokai";
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
          jakebecker.elixir-ls
          jdinhlife.gruvbox
          arrterian.nix-env-selector
          jnoortheen.nix-ide
          bbenoist.nix
          ms-azuretools.vscode-docker
          redhat.vscode-yaml
          yzhang.markdown-all-in-one
          betterthantomorrow.calva
          phoenixframework.phoenix
      ];
      userSettings = {
          "editor.fontSize" = 14;
          "window.zoomLevel" = 4;
          "workbench.colorTheme" = "Gruvbox Dark Hard";
          "terminal.integrated.enableMultiLinePasteWarning" = false;
          "editor.detectIndentation" = false;
          "editor.tabSize" = 2;
          "explorer.confirmDragAndDrop"= false;
      };
    }; 
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    vmware.host.enable = true;
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      font-awesome
      weather-icons
    ];
  };  

  services ={
    blueman = {
      enable = true;
    };
    flatpak = {
      enable = true;
    };
    gvfs = {
      enable = true;
    };
    openssh = {
      enable = true;
    };
    picom = {
      enable = true;  
      settings = {
        inactiveOpacity = 0.8; 
        corner-radius = 5;
      };
    }; 
    power-profiles-daemon = {
      enable = false;
    };
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80;

        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;

      };
    };
    xserver = {
      enable = true;
      displayManager = {
        autoLogin = {
          enable = true;
          user = "jasonk";
        };
        sddm = {
          enable = true;
          autoNumlock = true;
        };
      };
      layout = "us";
      libinput = {
        enable =true;
      };
      xkbVariant = "";    
      videoDrivers = [ "nvidia" ];  
      windowManager = {
        qtile = {
          enable = true;
        };
      };
    };
  };

  # Backup incase Qtile dies
  # services.xserver = {
  #   enable = true;
  #   desktopManager = {
  #     xterm.enable = false;
  #     xfce.enable = true;
  #   };
  #   displayManager.defaultSession = "xfce";
  # };

  # services.xserver.videoDrivers = [ "nvidia" ];
  # Configure keymap in X11
  # services.xserver = {
  #   layout = "us";
  #   xkbVariant = "";
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.hplip ];

  # services.gvfs.enable = true; 

  

  # services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];    
  };

  # services.power-profiles-daemon.enable = false;

  # services.tlp = {
  #     enable = true;
  #     settings = {
  #       CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #       CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

  #       CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #       CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

  #       CPU_MIN_PERF_ON_AC = 0;
  #       CPU_MAX_PERF_ON_AC = 100;
  #       CPU_MIN_PERF_ON_BAT = 0;
  #       CPU_MAX_PERF_ON_BAT = 80;

  #       START_CHARGE_THRESH_BAT0 = 75;
  #       STOP_CHARGE_THRESH_BAT0 = 80;

  #     };
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nvidia-offload 
    pkgs.libglvnd
    libpng
    libsecret
    appimage-run
    linuxKernel.packages.linux_zen.acpi_call
  ];

  

  

  system.stateVersion = "22.05"; # Did you read the comment?

  

  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
