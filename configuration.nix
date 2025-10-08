# NixOS System Configuration
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  # ===== IMPORTS =====
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # ===== NIX CONFIGURATION =====
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Add rust-overlay for nightly Rust
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
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
      
      # AMD Vulkan driver
      amdvlk
      
      # Mesa drivers (includes radv)
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      vulkan-validation-layers
      amdvlk
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
      sync.enable = true;  # Use NVIDIA GPU for everything
      
      # Bus IDs for your specific hardware
      amdgpuBusId = "PCI:8:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Environment variables for Vulkan
  environment.sessionVariables = {
    # Help Vulkan loader find ICD files
    AMD_VULKAN_ICD = "RADV";  # Use RADV by default for AMD
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
  };

  # ===== DESKTOP ENVIRONMENT =====
  # Enable the X11 windowing system
  services.xserver.enable = true;
  
  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  
  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable automatic login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jasonk";
  
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # ===== AUDIO =====
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===== PRINTING =====
  services.printing.enable = true;

  # ===== USERS & SECURITY =====
  # Configure sudo timeout (in minutes)
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';

  # Define user account
  users.users.jasonk = {
    isNormalUser = true;
    description = "jasonk";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # ===== HOME MANAGER =====
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.jasonk = import ./home.nix;

  # ===== SYSTEM PROGRAMS =====
  programs.firefox.enable = true;
  
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      (lib.getLib stdenv.cc.cc)  # glibc loader + base libs
      webkitgtk_4_0
      gtk3
      glib
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
  environment.systemPackages = with pkgs; [
    nodejs_24
    (callPackage ./codex.nix {})  # Build Codex from source
    claude-code
    vulkan-tools  # Fix vulkaninfo command

    # GNOME Shell Extensions
    gnomeExtensions.pop-shell
    gnomeExtensions.dock-from-dash
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