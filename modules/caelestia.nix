{ config, lib, pkgs, ... }:

{
  # ===== CAELESTIA SHELL CONFIGURATION =====
  # Using home-manager module for full configuration support
  programs.caelestia = {
    enable = true;

    # Enable systemd service to manage Caelestia shell
    systemd.enable = true;

    settings = {
      # CLI tool configuration
      cli = {
        theme = {
          enableTerm = true;
          enableHypr = true;
          enableDiscord = false;  # Not using Discord theming
          enableSpicetify = false;  # Not using Spotify
          enableFuzzel = false;  # Using Caelestia launcher
          enableBtop = true;
          enableGtk = true;
          enableQt = true;
        };
      };

      # Shell configuration
      general = {
        terminal = "foot";
        audio = "pavucontrol";
        fileManager = "thunar";

        idle = {
          # Disable all automatic locking and screen timeouts
          lockBeforeSleep = false;
          inhibitWhenAudio = false;
          timeouts = [];  # Empty array disables all idle actions (lock, dpms off, suspend)
        };
      };

      # Appearance settings
      appearance = {
        fonts = {
          sans = "Rubik";
          mono = "CaskaydiaCove NF";
          symbols = "Material Symbols Rounded";
        };
      };
    };
  };
}
