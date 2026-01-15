{ config, pkgs, lib, ... }:

{
  # ===== NIRI WINDOW MANAGER CONFIGURATION =====

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";

  # Niri configuration
  programs.niri.settings = {
    prefer-no-csd = true;

    spawn-at-startup = [
      { command = [ "update-vscode-theme" ]; }
      { command = [ "trigger-pywalfox" ]; }
    ];

    xwayland-satellite = {
      enable = true;
      path = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
    };

    outputs."DP-2" = {
      mode = {
        width = 3840;
        height = 1080;
        refresh = 59.968;
      };
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };

    outputs."eDP-1" = {
      mode = {
        width = 2560;
        height = 1600;
        refresh = 240.003;
      };
      scale = 1.0;
      position = {
        x = 10;
        y = -1600;
      };
    };

    layout = {
      preset-column-widths = [
        { proportion = 0.3333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; }
      ];
    };

    environment = {
      "QT_QPA_PLATFORMTHEME" = "qt6ct";
      "QT_QPA_PLATFORMTHEME_QT6" = "qt6ct";
    };

    binds = with config.lib.niri.actions; {
      # Help overlay and essential launchers
      "Mod+Shift+Slash".action = show-hotkey-overlay;
      "Mod+T".action = spawn "ghostty";
      "Mod+D".action = spawn "dms" "ipc" "spotlight" "toggle";
      "Mod+F".action = spawn "nautilus";
      "Mod+Q".action = close-window;

      # Screenshot with annotation
      "Print".action = spawn "screenshot-annotate";

      # Horizontal column navigation (focus)
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;

      # Move columns horizontally
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;

      # Workspace navigation (community defaults)
      "Mod+I".action = focus-workspace-down;
      "Mod+Down".action = focus-workspace-down;
      "Mod+U".action = focus-workspace-up;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Tab".action = focus-workspace-previous;

      # Move columns between workspaces
      "Mod+Shift+I".action = move-column-to-workspace-down;
      "Mod+Shift+Down".action = move-column-to-workspace-down;
      "Mod+Shift+U".action = move-column-to-workspace-up;
      "Mod+Shift+Up".action = move-column-to-workspace-up;

      # Overview toggle
      "Mod+O".action = toggle-overview;

      # Window resize controls
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-column-width-back;
      "Mod+Space".action = lib.mkForce fullscreen-window;
      "Mod+Equal".action = maximize-column;
    };
  };
}
