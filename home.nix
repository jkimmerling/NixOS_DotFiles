{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jasonk";
  home.homeDirectory = "/home/jasonk";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Disable version check since we're using development versions
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install for this user
  home.packages = with pkgs; [
    # Development tools
    git
    neovim
    tmux
    htop
    ripgrep
    fzf
    
    # Elixir and Erlang
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang
    
    # Gaming
    lutris
    wineWowPackages.stable  # Use stable instead of waylandFull for better clipboard support
    winetricks

    (let
        muhroLibs = with pkgs; [
          webkitgtk_4_0
          gtk3
          glib
          gsettings-desktop-schemas
          libsecret
          libsoup_3
          pango
          cairo
          harfbuzz
          at-spi2-core
          gdk-pixbuf
          libepoxy
          openssl
          krb5
          samba
        ];
      in pkgs.writeShellScriptBin "muhro-patcher" ''
        export WEBKIT_DISABLE_DMABUF_RENDERER=1
        export GSK_RENDERER=gl
        export GDK_BACKEND=x11
        export LD_LIBRARY_PATH="${lib.makeLibraryPath muhroLibs}:$LD_LIBRARY_PATH"
        cd /home/jasonk/Dot_Files/MuhRO
        exec ./Muh_Patcher "$@"
    '')
    
    # Clipboard utilities for Wine/Lutris
    xdotool
    xsel
    xclip
    wl-clipboard  # For Wayland clipboard support
    copyq  # Clipboard manager that helps with Wine/Wayland issues
    
    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    
    # Add more user-specific packages here

    # Chat
    discord-ptb
    signal-desktop

    # Networking
    samba
    krb5

    # Graphics
    gimp3

    # Audio
    tidal-hifi

  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "jasonk";
    userEmail = "your-email@example.com";  # Update with your email
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ".." = "cd ..";
      update = "sudo nixos-rebuild switch";
    };
  };

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Wine/Lutris environment variables
  home.sessionVariables = {
    # Force 32-bit Wine prefixes for better compatibility
    WINEARCH = "win32";
    # Force X11 backend for Wine games (fixes clipboard on Wayland)
    GDK_BACKEND = "x11";
    QT_QPA_PLATFORM = "xcb";
    # Enable Wine clipboard debugging (remove after fixing)
    # WINEDEBUG = "+clipboard";
  };

  # VS Code configuration (user-specific settings)
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Add VS Code extensions here
      ms-python.python
      ms-vscode.cpptools
      elixir-lsp.vscode-elixir-ls
      jdinhlife.gruvbox
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      bbenoist.nix
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      yzhang.markdown-all-in-one
      phoenixframework.phoenix
      ms-vscode-remote.remote-ssh
    ];
  };
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "green" ];
        size = "standard";
        variant = "macchiato";
      };
    };
  };

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark"; 
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dock-from-dash@fthx"
        "pop-shell@system76.com"
      ];
    };
  };
}