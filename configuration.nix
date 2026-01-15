# NixOS System Configuration
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  # ===== IMPORTS =====
  imports = [
    ./hardware-configuration.nix
    ./modules/power-management.nix
    ./modules/bluetooth.nix
    ./modules/nixos/system-base.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/gaming.nix
    ./modules/nixos/audio.nix
    ./modules/nixos/kdeconnect.nix
  ];

  # ===== NIX CONFIGURATION =====
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  # Allow insecure packages (needed for MuhRO Patcher)
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
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
