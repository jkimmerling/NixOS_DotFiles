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

  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Enable networking
  networking.hostName = "nixos";  
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Rainy_River";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };

  # Enable the KDE Plasma Desktop Environment.
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.sddm.enable = true; #TODO remove
    displayManager.sddm.autoNumlock = true;
    windowManager.qtile.enable = true; 
    displayManager.autoLogin = {
       enable = true;
       user = "jasonk";
     };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraGroups.vboxusers.members = [ "jasonk" ];
    users.jasonk = {
      isNormalUser = true;
      description = "jasonk";
      extraGroups = [ "networkmanager" "wheel" "docker"];
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
      chromium
      mono
      qbittorrent
      youtube-dl
      vmware-workstation
      libsForQt5.kdeconnect-kde
      gnome.gnome-calendar
      gnome-online-accounts
      gnome.gnome-keyring
      steam-run


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
      postman
      mysql-workbench
      rabbitmq-server

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

      '';
    };


    services.picom = {
      enable = true;   
      settings.inactiveOpacity = 0.8; 
      settings.corner-radius = 5;
        #   opacity-rule = [
        #       "80:class_g = 'Alacritty'",
        #   ];
        # '';
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
          ms-python.python
          ms-azuretools.vscode-docker
          redhat.vscode-yaml
          yzhang.markdown-all-in-one
          betterthantomorrow.calva
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

  
  services.printing.drivers = [ pkgs.hplip ];

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    vmware.host.enable = true;
    # virtualbox.host = {
    #   enable = true;
    #   enableExtensionPack = true;
    # };
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      font-awesome
      weather-icons
    ];
  };  

  services.gvfs.enable = true; 


  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    
  };
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ]; 
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nvidia-offload 
    pkgs.libglvnd
    libpng
    libsecret
    appimage-run
  ];

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "22.05"; # Did you read the comment?

  nixpkgs.overlays = [
    (self: super: {
      fcitx-engines = pkgs.fcitx5;
    })
  ];

  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
