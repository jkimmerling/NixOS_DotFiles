{ config, pkgs, lib, ... }:

{
  # ===== DANKMATERIALSHELL CONFIGURATION =====

  # DankMaterialShell configuration
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    enableAudioWavelength = true;
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };

  # Additional niri configuration (merged with DMS)
  home.file."Pictures/Screenshots/.keep".text = "";

  programs.niri.settings = {
    spawn-at-startup = [
      { command = [ "update-vscode-theme" ]; }
      { command = [ "trigger-pywalfox" ]; }
    ];

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

  };

  # Ghostty terminal theming hook for DMS auto-generated palette
  xdg.configFile."ghostty/config".text = ''
    config-file = config-dankcolors
    app-notifications = no-clipboard-copy,no-config-reload
  '';

  # Clipboard history watcher - monitors clipboard and saves to cliphist
  systemd.user.services.cliphist-watcher = {
    Unit = {
      Description = "Clipboard history watcher for cliphist";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
