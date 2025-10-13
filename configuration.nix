# NixOS System Configuration
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

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
  # ===== IMPORTS =====
  imports = [
    ./hardware-configuration.nix
    ./modules/power-management.nix
    ./modules/bluetooth.nix
  ];

  # ===== NIX CONFIGURATION =====
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages (needed for MuhRO Patcher)
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];
  
  # Automatic garbage collection
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ===== BOOT & FILESYSTEM =====
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # ===== NETWORKING =====
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ===== LOCALIZATION =====
  time.timeZone = "America/Chicago";
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

  # ===== GRAPHICS & DISPLAY =====
  # Enable Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer

      # Mesa drivers (includes RADV for AMD)
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      vulkan-validation-layers
      mesa
    ];
  };

  # NVIDIA configuration
  hardware.nvidia = {
    # Use open source kernel modules (RTX 4070 supports this)
    open = true;
    
    # Modesetting is required
    modesetting.enable = true;
    
    # Nvidia power management (optional but recommended for laptops)
    powerManagement.enable = false; # Experimental, can cause sleep issues
    powerManagement.finegrained = false; # Turns off GPU when not in use
    
    # Use the NVidia open kernel module
    nvidiaSettings = true;
    
    # Select the driver version (use production for stability)
    package = config.boot.kernelPackages.nvidiaPackages.production;
    
    # PRIME configuration for hybrid graphics
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:8:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Environment variables for Vulkan
  environment.sessionVariables = {
    # Help Vulkan loader find ICD files for both AMD and NVIDIA
    AMD_VULKAN_ICD = "RADV";  # Use RADV by default for AMD
    # Explicitly select NVIDIA's 64-bit and 32-bit Vulkan ICDs for Wine/DXVK
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
    NIXOS_OZONE_WL = "1";
  };

  # ===== DESKTOP ENVIRONMENT =====
  programs.niri.enable = true;

  # Enable the X11 windowing system for XWayland
  services.xserver.enable = true;

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable SDDM display manager for Niri
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable automatic login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jasonk";
  services.displayManager.defaultSession = "niri";

  # ===== AUDIO =====
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 512;
        default.clock.min-quantum = 512;
        default.clock.max-quantum = 512;
      };
    };
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # ===== PRINTING =====
  services.printing.enable = true;

  # ===== KEYRING =====
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM to automatically unlock keyring on login
  # Use 'login' instead of 'sddm' since we don't use a display manager
  security.pam.services.login.enableGnomeKeyring = true;

  # ===== USERS & SECURITY =====
  # Configure sudo timeout (in minutes)
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';

  # Allow passwordless sudo for NixOS rebuild commands
  security.sudo.extraRules = [
    {
      users = [ "jasonk" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Define user account
  users.users.jasonk = {
    isNormalUser = true;
    description = "jasonk";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # ===== HOME MANAGER =====
  # Now configured in flake.nix

  # ===== SYSTEM PROGRAMS =====
  programs.firefox.enable = true;
  
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    # Force NVIDIA PRIME offload for all Steam games
    package = pkgs.steam.override {
      extraEnv = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.kdeconnect.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      (lib.getLib stdenv.cc.cc)  # glibc loader + base libs
      webkitgtk_4_0
      gtk3
      glib
      glib-networking
      gsettings-desktop-schemas
      libsecret
      libsoup_3
      pango
      cairo
      harfbuzz
      at-spi2-core
      gdk-pixbuf
      libepoxy
      openssl
    ];
  };

  # ===== SYSTEM PACKAGES =====
  environment.systemPackages =
    (with pkgs; [
      nodejs_24
      (callPackage ./derivations/codex.nix {})  # Build Codex from source
      (callPackage ./derivations/claude-code-latest.nix {})
      vulkan-tools  # Fix vulkaninfo command
      mesa-demos

      # Wayland utilities
      dunst
      wl-clipboard
      grim
      slurp
      swappy
      networkmanagerapplet

      mesa-demos
    ])
    ++ [
      nvidia-offload
    ];

  # ===== SYSTEM STATE =====
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
