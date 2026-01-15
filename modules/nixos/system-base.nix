{ config, pkgs, ... }:

{
  # ===== BOOT & FILESYSTEM =====
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # Limit number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;

  # AMD GPU kernel parameters to prevent crashes
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"           # Enable automatic GPU recovery
    "amdgpu.ppfeaturemask=0xffffffff" # Enable all power play features
    "amdgpu.dpm=1"                    # Enable dynamic power management
  ];

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

  # ===== DESKTOP ENVIRONMENT =====
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;  # Use unstable for include support (v25.11+)

  # Enable the X11 windowing system for XWayland
  services.xserver.enable = true;

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

  # ===== PRINTING =====
  services.printing.enable = true;

  # ===== REMOVABLE MEDIA =====
  # Enable udisks2 for automounting USB drives and other removable media
  services.udisks2.enable = true;
  # Enable GVFS for desktop integration (Nautilus, etc.)
  services.gvfs.enable = true;

  # ===== KEYRING =====
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM to automatically unlock keyring on login
  security.pam.services.sddm.enableGnomeKeyring = true;
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
          command = "/run/current-system/sw/bin/nixos-rebuild switch --flake /home/jasonk/Dot_Files\\#nixos";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Define user account
  users.users.jasonk = {
    isNormalUser = true;
    description = "jasonk";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # ===== SYSTEM PROGRAMS =====
  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # ===== VIRTUALIZATION =====
  # Enable Docker with auto-start daemon
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      (lib.getLib stdenv.cc.cc)  # glibc loader + base libs
      webkitgtk_4_1
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

  # ===== GARBAGE COLLECTION =====
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  # Optimize nix store weekly
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Mouse
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # ===== SYSTEM PACKAGES =====
  environment.systemPackages = with pkgs; [
    nodejs_24
    # (callPackage ../../derivations/codex.nix {})  # Build Codex from source
    (callPackage ../../derivations/claude-code-latest.nix {})

    # Wayland utilities
    dunst
    wl-clipboard
    grim
    slurp
    swappy
    satty
    networkmanagerapplet
  ];
}
