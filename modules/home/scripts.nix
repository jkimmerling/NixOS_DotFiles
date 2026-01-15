{ config, pkgs, ... }:

{
  # ===== INLINE SHELL SCRIPTS =====
  # Custom scripts with proper Nix paths embedded

  home.packages = with pkgs; [
    # Screenshot with annotation - grim + slurp + satty
    (writeShellScriptBin "screenshot-annotate" ''
      ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${satty}/bin/satty --filename - --fullscreen --copy-command ${wl-clipboard}/bin/wl-copy --output-filename ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
    '')

    # Trigger Pywalfox to update Firefox theme on startup
    (writeShellScriptBin "trigger-pywalfox" ''
      # Wait for Firefox to be running
      for i in {1..30}; do
        if ${procps}/bin/pgrep -x firefox >/dev/null; then
          # Give Firefox time to fully start and load extensions
          sleep 5
          # Trigger pywalfox update command
          ${pywalfox-native}/bin/pywalfox update >/dev/null 2>&1 || true
          break
        fi
        sleep 1
      done
    '')

    # Script to generate VS Code theme from DMS colors
    (writeShellScriptBin "update-vscode-theme" ''
      DMS_COLORS="$HOME/.cache/quickshell/dankshell/dms-colors.json"
      THEME_DIR="$HOME/.vscode/extensions/dms-theme"

      if [ ! -f "$DMS_COLORS" ]; then
        echo "Warning: DMS colors file not found at $DMS_COLORS"
        exit 0
      fi

      # Create theme directory
      mkdir -p "$THEME_DIR/themes"

      # Create package.json (only if it doesn't exist)
      if [ ! -f "$THEME_DIR/package.json" ]; then
        cat > "$THEME_DIR/package.json" << 'PKG_EOF'
{
  "name": "dms-theme",
  "displayName": "DMS Theme",
  "description": "Auto-generated theme from DankMaterialShell colors",
  "version": "1.0.0",
  "engines": {
    "vscode": "^1.0.0"
  },
  "categories": ["Themes"],
  "contributes": {
    "themes": [
      {
        "label": "DMS Dark",
        "uiTheme": "vs-dark",
        "path": "./themes/dms-dark.json"
      }
    ]
  }
}
PKG_EOF
      fi

      # Read colors using jq
      BACKGROUND=$(${jq}/bin/jq -r '.colors.dark.background' "$DMS_COLORS")
      ON_BACKGROUND=$(${jq}/bin/jq -r '.colors.dark.on_background' "$DMS_COLORS")
      PRIMARY=$(${jq}/bin/jq -r '.colors.dark.primary' "$DMS_COLORS")
      ON_PRIMARY=$(${jq}/bin/jq -r '.colors.dark.on_primary' "$DMS_COLORS")
      PRIMARY_CONTAINER=$(${jq}/bin/jq -r '.colors.dark.primary_container' "$DMS_COLORS")
      ON_PRIMARY_CONTAINER=$(${jq}/bin/jq -r '.colors.dark.on_primary_container' "$DMS_COLORS")
      SECONDARY=$(${jq}/bin/jq -r '.colors.dark.secondary' "$DMS_COLORS")
      SECONDARY_FIXED_DIM=$(${jq}/bin/jq -r '.colors.dark.secondary_fixed_dim' "$DMS_COLORS")
      TERTIARY=$(${jq}/bin/jq -r '.colors.dark.tertiary' "$DMS_COLORS")
      ERROR=$(${jq}/bin/jq -r '.colors.dark.error' "$DMS_COLORS")
      SURFACE=$(${jq}/bin/jq -r '.colors.dark.surface' "$DMS_COLORS")
      SURFACE_DIM=$(${jq}/bin/jq -r '.colors.dark.surface_dim' "$DMS_COLORS")
      SURFACE_CONTAINER=$(${jq}/bin/jq -r '.colors.dark.surface_container' "$DMS_COLORS")
      SURFACE_CONTAINER_LOW=$(${jq}/bin/jq -r '.colors.dark.surface_container_low' "$DMS_COLORS")
      SURFACE_CONTAINER_HIGH=$(${jq}/bin/jq -r '.colors.dark.surface_container_high' "$DMS_COLORS")
      SURFACE_CONTAINER_HIGHEST=$(${jq}/bin/jq -r '.colors.dark.surface_container_highest' "$DMS_COLORS")
      ON_SURFACE=$(${jq}/bin/jq -r '.colors.dark.on_surface' "$DMS_COLORS")
      OUTLINE=$(${jq}/bin/jq -r '.colors.dark.outline' "$DMS_COLORS")
      OUTLINE_VARIANT=$(${jq}/bin/jq -r '.colors.dark.outline_variant' "$DMS_COLORS")
      PRIMARY_FIXED_DIM=$(${jq}/bin/jq -r '.colors.dark.primary_fixed_dim' "$DMS_COLORS")

      # Generate theme JSON
      cat > "$THEME_DIR/themes/dms-dark.json" << THEME_EOF
{
  "name": "DMS Dark",
  "type": "dark",
  "colors": {
    "editor.background": "$BACKGROUND",
    "editor.foreground": "$ON_BACKGROUND",
    "editorLineNumber.foreground": "$OUTLINE",
    "editorLineNumber.activeForeground": "$PRIMARY",
    "editorCursor.foreground": "$PRIMARY",
    "editor.selectionBackground": "$PRIMARY_CONTAINER",
    "editor.inactiveSelectionBackground": "$SURFACE_CONTAINER",
    "activityBar.background": "$SURFACE_CONTAINER",
    "activityBar.foreground": "$ON_SURFACE",
    "activityBar.activeBorder": "$PRIMARY",
    "activityBarBadge.background": "$PRIMARY",
    "activityBarBadge.foreground": "$ON_PRIMARY",
    "sideBar.background": "$SURFACE_CONTAINER_LOW",
    "sideBar.foreground": "$ON_SURFACE",
    "sideBarSectionHeader.background": "$SURFACE_CONTAINER",
    "statusBar.background": "$SURFACE_CONTAINER",
    "statusBar.foreground": "$ON_SURFACE",
    "statusBar.noFolderBackground": "$SURFACE_CONTAINER",
    "titleBar.activeBackground": "$SURFACE_CONTAINER",
    "titleBar.activeForeground": "$ON_SURFACE",
    "titleBar.inactiveBackground": "$SURFACE_CONTAINER_LOW",
    "titleBar.inactiveForeground": "$OUTLINE",
    "tab.activeBackground": "$SURFACE_CONTAINER_HIGH",
    "tab.activeForeground": "$ON_SURFACE",
    "tab.inactiveBackground": "$SURFACE_CONTAINER_LOW",
    "tab.inactiveForeground": "$OUTLINE",
    "tab.border": "$OUTLINE_VARIANT",
    "panel.background": "$SURFACE_CONTAINER",
    "panel.border": "$OUTLINE_VARIANT",
    "panelTitle.activeBorder": "$PRIMARY",
    "panelTitle.activeForeground": "$ON_SURFACE",
    "terminal.background": "$SURFACE",
    "terminal.foreground": "$ON_SURFACE",
    "terminal.ansiBlack": "$SURFACE_DIM",
    "terminal.ansiRed": "$ERROR",
    "terminal.ansiGreen": "$TERTIARY",
    "terminal.ansiYellow": "$SECONDARY",
    "terminal.ansiBlue": "$PRIMARY",
    "terminal.ansiMagenta": "$PRIMARY",
    "terminal.ansiCyan": "$TERTIARY",
    "terminal.ansiWhite": "$ON_SURFACE",
    "list.activeSelectionBackground": "$PRIMARY_CONTAINER",
    "list.activeSelectionForeground": "$ON_PRIMARY_CONTAINER",
    "list.inactiveSelectionBackground": "$SURFACE_CONTAINER_HIGH",
    "list.hoverBackground": "$SURFACE_CONTAINER_HIGHEST",
    "input.background": "$SURFACE_CONTAINER_HIGHEST",
    "input.foreground": "$ON_SURFACE",
    "input.border": "$OUTLINE",
    "inputOption.activeBorder": "$PRIMARY",
    "button.background": "$PRIMARY",
    "button.foreground": "$ON_PRIMARY",
    "button.hoverBackground": "$PRIMARY_CONTAINER",
    "notificationCenter.border": "$OUTLINE",
    "notifications.background": "$SURFACE_CONTAINER_HIGH",
    "notifications.foreground": "$ON_SURFACE",
    "gitDecoration.modifiedResourceForeground": "$TERTIARY",
    "gitDecoration.deletedResourceForeground": "$ERROR",
    "gitDecoration.untrackedResourceForeground": "$SECONDARY",
    "gitDecoration.ignoredResourceForeground": "$OUTLINE",
    "gitDecoration.conflictingResourceForeground": "$ERROR"
  },
  "tokenColors": [
    {
      "scope": ["comment"],
      "settings": {
        "foreground": "$OUTLINE"
      }
    },
    {
      "scope": ["string"],
      "settings": {
        "foreground": "$TERTIARY"
      }
    },
    {
      "scope": ["keyword", "storage"],
      "settings": {
        "foreground": "$PRIMARY"
      }
    },
    {
      "scope": ["variable", "entity.name"],
      "settings": {
        "foreground": "$ON_SURFACE"
      }
    },
    {
      "scope": ["constant", "support.constant"],
      "settings": {
        "foreground": "$SECONDARY"
      }
    },
    {
      "scope": ["entity.name.function", "support.function"],
      "settings": {
        "foreground": "$PRIMARY_FIXED_DIM"
      }
    },
    {
      "scope": ["entity.name.type", "entity.name.class", "support.class"],
      "settings": {
        "foreground": "$SECONDARY_FIXED_DIM"
      }
    }
  ]
}
THEME_EOF
    '')
  ];
}
