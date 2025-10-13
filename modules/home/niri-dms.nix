{ config, pkgs, lib, ... }:

let
  updateFuzzelTheme = pkgs.writeShellScriptBin "update-fuzzel-theme" ''
    # Auto-generate fuzzel config from DMS theme colors
    GTK_CSS="$HOME/.config/gtk-3.0/gtk.css"
    FUZZEL_INI="$HOME/.config/fuzzel/fuzzel.ini"

    # Extract background (dark)
    BG=$(${pkgs.gawk}/bin/awk '/^\.background \{/{getline; if(/background-color/) {match($0, /#[0-9a-f]{6}/); print substr($0, RSTART+1, 6)}}' "$GTK_CSS")
    # Extract foreground (light text)
    FG=$(${pkgs.gawk}/bin/awk '/^\.background \{/{getline; getline; if(/color/) {match($0, /#[0-9a-f]{6}/); print substr($0, RSTART+1, 6)}}' "$GTK_CSS")
    # Extract accent
    ACCENT=$(${pkgs.gawk}/bin/awk '/background-color.*#9fd49b/{match($0, /#[0-9a-f]{6}/); print substr($0, RSTART+1, 6); exit}' "$GTK_CSS")

    # Defaults
    BG=''${BG:-10140f}
    FG=''${FG:-e0e4db}
    ACCENT=''${ACCENT:-9fd49b}

    cat > "$FUZZEL_INI" << FUZZEL_EOF
font=JetBrains Mono NF:size=17
terminal=foot -e
prompt="> "
layer=overlay
lines=15
width=60
dpi-aware=no
inner-pad=10
horizontal-pad=40
vertical-pad=15
match-counter=yes

[colors]
background=''${BG}dd
text=''${FG}ff
prompt=''${ACCENT}ff
placeholder=918f9aff
input=''${FG}ff
match=''${ACCENT}ff
selection=''${ACCENT}87
selection-text=10140fff
selection-match=10140fff
counter=918f9aff
border=''${ACCENT}77

[border]
radius=10
width=2
FUZZEL_EOF
  '';
in
{
  # ===== DESKTOP CONFIGURATION =====

  # User packages for Niri/DMS
  home.packages = with pkgs; [
    fuzzel
    updateFuzzelTheme
  ];

  # Niri configuration
  programs.niri.settings = {
    prefer-no-csd = true;

    spawn-at-startup = [
      { command = [ "${updateFuzzelTheme}/bin/update-fuzzel-theme" ]; }
    ];

    xwayland-satellite = {
      enable = true;
      path = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
    };

    outputs."eDP-1" = {
      mode = {
        width = 2560;
        height = 1600;
        refresh = 240.003;
      };
      scale = 1.0;
    };

    layout = {
      preset-column-widths = [
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
      "Mod+D".action = spawn "fuzzel";
      "Mod+Q".action = close-window;

      # Horizontal column navigation (focus)
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;

      # Vertical window navigation (focus)
      "Mod+Down".action = focus-window-down;
      "Mod+Up".action = focus-window-up;

      # Move columns horizontally
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;

      # Workspace navigation (community defaults)
      "Mod+I".action = focus-workspace-down;
      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+U".action = focus-workspace-up;
      "Mod+Page_Up".action = focus-workspace-up;
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
      "Mod+F".action = fullscreen-window;
      "Mod+Equal".action = maximize-column;
    };
  };

  # DankMaterialShell configuration
  programs.dankMaterialShell = {
    enable = true;
    enableSystemd = false;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableBrightnessControl = true;
    enableNightMode = true;
    enableAudioWavelength = true;
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };

  # GTK theme configuration
  # Note: Colloid must be manually installed to ~/.themes/ for DMS integration
  # Run: git clone https://github.com/vinceliuice/Colloid-gtk-theme && cd Colloid-gtk-theme && ./install.sh -s standard -l --tweaks normal
  gtk = {
    enable = true;
    theme = {
      name = "Colloid";
    };
    iconTheme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
    };
  };

  # Ghostty terminal theming hook for DMS auto-generated palette
  xdg.configFile."ghostty/config".text = ''
    config-file = config-dankcolors
    app-notifications = no-clipboard-copy,no-config-reload
  '';

  # Matugen -> Pywalfox palette symlink to keep Firefox colors up to date
  home.activation.pywalfoxPaletteLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/.cache/wal"
    ln -sf "${config.home.homeDirectory}/.cache/wal/dank-pywalfox.json" \
      "${config.home.homeDirectory}/.cache/wal/colors.json"
  '';

  # Install Colloid GTK theme for DMS integration
  # Must be in ~/.themes/ (not /nix/store) so DMS can modify it
  home.activation.installColloidTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    THEME_DIR="${config.home.homeDirectory}/.themes"
    COLLOID_INSTALLED="$THEME_DIR/Colloid/gtk-3.0/gtk.css"

    # Only install if not already present
    if [ ! -f "$COLLOID_INSTALLED" ]; then
      echo "Installing Colloid theme for DMS integration..."

      # Create temp directory
      TEMP_DIR=$(${pkgs.coreutils}/bin/mktemp -d)
      cd "$TEMP_DIR"

      # Clone Colloid theme
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/vinceliuice/Colloid-gtk-theme.git
      cd Colloid-gtk-theme

      # Install with DMS-recommended flags
      ${pkgs.nix}/bin/nix-shell -p sassc --run "./install.sh -s standard -l --tweaks normal" || true

      # Cleanup
      cd
      ${pkgs.coreutils}/bin/rm -rf "$TEMP_DIR"

      echo "✓ Colloid theme installed to $THEME_DIR"
    fi
  '';

  # Ensure the Pywalfox native host is installed for Firefox integration
  # Note: Pywalfox doesn't run as a daemon - Firefox starts it via native messaging
  home.activation.pywalfoxInstall = lib.hm.dag.entryAfter [ "pywalfoxPaletteLink" ] ''
    ${pkgs.pywalfox-native}/bin/pywalfox install >/dev/null 2>&1 || true
  '';

  # File watcher to regenerate fuzzel theme when GTK CSS changes
  systemd.user.services.fuzzel-theme-watcher = {
    Unit = {
      Description = "Watch GTK CSS and regenerate fuzzel theme";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "watch-gtk-css" ''
        while ${pkgs.inotify-tools}/bin/inotifywait -e modify,create,close_write $HOME/.config/gtk-3.0/gtk.css 2>/dev/null; do
          ${updateFuzzelTheme}/bin/update-fuzzel-theme
        done
      ''}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
