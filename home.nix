{ config, pkgs, lib, ... }:

{
  # ===== IMPORTS =====
  imports = [
    ./modules/home/development.nix
    ./modules/home/gaming.nix
    ./modules/home/shell.nix
    ./modules/home/niri-dms.nix
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
    tidal-hifi

    # Desktop Integration
    nautilus
    ghostty
    pywalfox-native
  ];
}
