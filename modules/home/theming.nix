{ config, pkgs, lib, ... }:

{
  # ===== THEMING CONFIGURATION =====

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

  # Note: VSCode Material Code extension reads directly from DMS colors at:
  # ~/.cache/quickshell/dankshell/dms-colors.json

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

  # Matugen -> Pywalfox palette symlink to keep Firefox colors up to date
  home.activation.pywalfoxPaletteLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/.cache/wal"
    ln -sf "${config.home.homeDirectory}/.cache/wal/dank-pywalfox.json" \
      "${config.home.homeDirectory}/.cache/wal/colors.json"
  '';

  # Ensure the Pywalfox native host is installed for Firefox integration
  # Note: Pywalfox doesn't run as a daemon - Firefox starts it via native messaging
  home.activation.pywalfoxInstall = lib.hm.dag.entryAfter [ "pywalfoxPaletteLink" ] ''
    ${pkgs.pywalfox-native}/bin/pywalfox install >/dev/null 2>&1 || true
  '';

  # File watcher to regenerate themes when DMS colors change
  # VSCode extension automatically reloads the theme when the file changes
  # Firefox reloads via pywalfox update command
  systemd.user.services.dms-theme-watcher = {
    Unit = {
      Description = "Watch DMS colors and regenerate application themes";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "watch-dms-colors" ''
        while ${pkgs.inotify-tools}/bin/inotifywait -e modify,create,close_write $HOME/.cache/quickshell/dankshell/dms-colors.json 2>/dev/null; do
          ${config.home.profileDirectory}/bin/update-vscode-theme
          sleep 0.1
          ${pkgs.pywalfox-native}/bin/pywalfox update >/dev/null 2>&1 || true
        done
      ''}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
