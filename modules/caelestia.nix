{ config, lib, pkgs, ... }:

{
  # ===== CAELESTIA SHELL CONFIGURATION =====
  # Using home-manager module for full configuration support
  programs.caelestia = {
    enable = true;

    # Enable systemd service to manage Caelestia shell
    systemd.enable = true;

    settings = {
      general = {
        idle = {
          # Disable all automatic locking and screen timeouts
          lockBeforeSleep = false;
          inhibitWhenAudio = false;
          timeouts = [];  # Empty array disables all idle actions (lock, dpms off, suspend)
        };
      };
    };
  };
}
