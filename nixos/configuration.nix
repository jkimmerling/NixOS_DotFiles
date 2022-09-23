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
  users.users.jasonk = {
    isNormalUser = true;
    description = "jasonk";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      firefox
      kate
      git
      dconf
    ];
  };

  programs.dconf.enable = true;

  home-manager.users.jasonk = { pkgs, ... }: {
    home.username = "jasonk";
    home.homeDirectory = "/home/jasonk";

    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [ 
      #Package runners
      appimage-run
      
      # Screenshots
      flameshot

      #Gaming
      lutris
      steam
      wineWowPackages.staging
      winetricks
      mesa
      glxinfo


      picom
      networkmanagerapplet

      #Sensors
      pciutils
      acpi
      lm_sensors
      tlp

      #System info
      glances

      #Chat / Community
      discord
      slack

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

      #Archiving
      zip
      unzip

      #development
      vscode
      direnv
      postman

      #Virtualization
      docker-compose

      #Docs
      libreoffice

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
      neofetch
      
    ];

    gtk = {
      enable = true;
      font.name = "Droid Sans Mono 20";
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
        
        init-elixir () {
          cp ~/NixOS_DotFiles/nix-shells/elixir/shell.nix ./
          nix-shell
        }

        init-airflow () {
          cp ~/NixOS_DotFiles/nix-shells/python/airflow/shell.nix ./
          nix-shell
        }

      '';
    };


    services.picom = {
      enable = true;   
      inactiveOpacity = "0.8"; 
      extraOptions = ''
          corner-radius = 5;
          opacity-rule = [
              "80:class_g = 'Alacritty'",
          ];
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
          ms-python.python
          ms-azuretools.vscode-docker
          redhat.vscode-yaml
          yzhang.markdown-all-in-one
      ];
      userSettings = {
          "editor.fontSize" = 14;
          "window.zoomLevel" = 4;
          "workbench.colorTheme" = "Gruvbox Dark Hard";
      };
    }; 
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nvidia-offload 
    pkgs.libglvnd
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

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
