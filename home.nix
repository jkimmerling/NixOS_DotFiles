{ config, pkgs, lib, ... }:

{
  # ===== IMPORTS =====
  imports = [
    ./modules/home/development.nix
    ./modules/home/gaming.nix
    ./modules/home/shell.nix
    ./modules/home/scripts.nix
    ./modules/home/niri.nix  # Additional niri settings merged with DMS
    ./modules/home/dms.nix
    ./modules/home/theming.nix
  ];

  # ===== HOME MANAGER CONFIGURATION =====
  home.username = "jasonk";
  home.homeDirectory = "/home/jasonk";
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # ===== USER PACKAGES =====
  # Basic packages not specific to other modules
  home.packages = with pkgs; [
    htop
    ripgrep
    fzf
    eza

    # Note taking
    anytype

    # Communication
    discord-ptb
    signal-desktop

    # Graphics & Media
    gimp3
    inkscape
    tidal-hifi

    # Desktop Integration
    nautilus
    gvfs  # Required for Nautilus to access removable media
    ghostty
    pywalfox-native
  ];

  # ===== PROGRAMS =====
  # OBS Studio for screen recording
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs  # Wayland screen capture
      obs-pipewire-audio-capture  # Audio capture
      obs-vkcapture  # Vulkan/OpenGL capture
    ];
  };

  # ===== SERVICES =====
  # Automount removable media
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };

  # ===== DESKTOP ENTRIES =====
  xdg.desktopEntries.signal = {
    name = "Signal";
    genericName = "Instant Messaging";
    comment = "Private messaging from your desktop";
    exec = "signal-desktop --password-store=gnome-libsecret %U";
    icon = "signal-desktop";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" "Chat" ];
    mimeType = [ "x-scheme-handler/sgnl" "x-scheme-handler/signalcaptcha" ];
  };

  # ===== DEFAULT APPLICATIONS =====
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
