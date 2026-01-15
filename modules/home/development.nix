{ config, pkgs, lib, ... }:

{
  # ===== DEVELOPMENT CONFIGURATION =====

  home.packages = with pkgs; [
    # Development Tools
    git
    neovim
    tmux
    nodejs_24
    bun  # For running material-code theme generator
    docker-compose
    redisinsight
    chromium
    imagemagick
    ghostscript
    jdk21  # Java Development Kit (LTS)
    android-studio-full
    google-cloud-sdk
    vlc

    # Documentation
    libreoffice-qt
    typora

    # video conf
    zoom-us

    # Custom wrapped tools
    (pkgs.symlinkJoin {
      name = "pgadmin4-wrapped";
      paths = [ pkgs.pgadmin4 ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pgadmin4 \
          --run 'mkdir -p "$HOME/.pgadmin"' \
          --set PGADMIN_SERVER_MODE "OFF" \
          --set PGADMIN_SETUP_EMAIL "jkimmerling@protonmail.com" \
          --set PGADMIN_SETUP_PASSWORD "admin"
      '';
    })

    (pkgs.writeShellScriptBin "init-elixir" ''
      exec ${pkgs.bash}/bin/bash ${config.home.homeDirectory}/Dot_Files/scripts/init-elixir.sh "$@"
    '')

    (pkgs.writeShellScriptBin "init-phx" ''
      exec ${pkgs.bash}/bin/bash ${config.home.homeDirectory}/Dot_Files/scripts/init-phx.sh "$@"
    '')

    (pkgs.writeShellScriptBin "gd-stash" ''
      # Ensure xwayland-satellite is running
      if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet xwayland-satellite; then
        ${pkgs.systemd}/bin/systemctl --user start xwayland-satellite
        sleep 1
      fi

      # Set Java environment variables for Wayland compatibility
      export _JAVA_AWT_WM_NONREPARENTING=1
      export AWT_TOOLKIT=MToolkit

      # Run GDStash
      cd "${config.home.homeDirectory}/Dot_Files/GD Stash-2-1-8-1f-1750802824"
      exec ${pkgs.jdk21}/bin/java -Xms1024m -Xmx1024m -jar GDStash.jar "$@"
    '')

    # Programming Languages
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "jasonk";
        email = "jkimmerling@protonmail.com";
      };
      push = {
        autoSetupRemote = true;  # Automatically set upstream when pushing new branches
      };
      branch = {
        autoSetupMerge = "always";  # Automatically set up tracking for new branches
      };
    };
  };

  # VS Code configuration with mutable settings for theme auto-reload
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;  # Allow installing extensions manually

    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "DMS Dark";
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.scrollback" = 10000;
      };

      extensions = with pkgs.vscode-extensions; [
      # Python
      ms-python.python

      # C/C++
      ms-vscode.cpptools

      # Elixir
      elixir-lsp.vscode-elixir-ls
      phoenixframework.phoenix

      # Nix
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      bbenoist.nix

      # DevOps
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      ms-vscode-remote.remote-ssh
      ms-azuretools.vscode-containers

      # Editor enhancements
      jdinhlife.gruvbox
      yzhang.markdown-all-in-one
      ];
    };
  };

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Keep Firefox links on the current workspace while reusing the existing profile
  programs.firefox = {
    enable = true;
    profiles."jason-main" = {
      path = "3n2y12vq.default";
      isDefault = true;
      extraConfig = ''
        user_pref("widget.disable-workspace-management", true);
      '';
    };
  };
}
