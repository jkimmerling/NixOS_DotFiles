{ config, pkgs, ... }:

{
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

  # ===== DESKTOP ENVIRONMENT =====
  programs.niri.enable = true;

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

  # ===== SYSTEM PROGRAMS =====
  programs.firefox.enable = true;

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
  environment.systemPackages = with pkgs; [
    nodejs_24
    (callPackage ../../derivations/codex.nix {})  # Build Codex from source
    (callPackage ../../derivations/claude-code-latest.nix {})

    # Wayland utilities
    dunst
    wl-clipboard
    grim
    slurp
    swappy
    networkmanagerapplet
  ];
}
