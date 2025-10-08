{ config, pkgs, lib, ... }:

let
  # MuhRO Patcher script
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
  
  muhroPatcher = pkgs.writeShellScriptBin "muhro-patcher" ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export GSK_RENDERER=gl
    export GDK_BACKEND=x11
    export LD_LIBRARY_PATH="${lib.makeLibraryPath muhroLibs}:$LD_LIBRARY_PATH"
    cd /home/jasonk/Dot_Files/MuhRO
    exec ./Muh_Patcher "$@"
  '';
in
{
  # ===== HOME MANAGER CONFIGURATION =====
  home.username = "jasonk";
  home.homeDirectory = "/home/jasonk";
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # ===== USER PACKAGES =====
  home.packages = with pkgs; [
    # === Development Tools ===
    git
    neovim
    tmux
    htop
    ripgrep
    fzf
    nodejs_24
    
    # === Programming Languages ===
    # Elixir and Erlang
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang
    
    # === Gaming & Wine ===
    lutris
    wineWowPackages.stable
    winetricks
    muhroPatcher
    
    # Wine/X11 clipboard utilities
    xdotool
    xsel
    xclip
    wl-clipboard
    copyq
    
    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    
    # === Communication ===
    discord-ptb
    signal-desktop
    
    # === Graphics & Media ===
    gimp3
    tidal-hifi
    
    # === System & Networking ===
    samba
    krb5
  ];

  # ===== DEVELOPMENT CONFIGURATION =====
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "jasonk";
    userEmail = "jkimmerling@protonmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;  # Automatically set upstream when pushing new branches
      };
      branch = {
        autoSetupMerge = "always";  # Automatically set up tracking for new branches
      };
    };
  };

  # VS Code configuration
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
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
      
      # Editor enhancements
      jdinhlife.gruvbox
      yzhang.markdown-all-in-one
    ];
  };
  
  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ===== SHELL CONFIGURATION =====
  
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

  # ===== ENVIRONMENT VARIABLES =====
  
  home.sessionVariables = {
    # Wine/Lutris configuration for better game compatibility
    WINEARCH = "win32";  # Force 32-bit Wine prefixes
    GDK_BACKEND = "x11";  # Force X11 backend for Wine games (fixes clipboard on Wayland)
    QT_QPA_PLATFORM = "xcb";
  };

  # ===== DESKTOP CONFIGURATION =====
  
  # GTK theme configuration
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

  # GNOME configuration via dconf
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "dock-from-dash@fthx"
          "pop-shell@system76.com"
        ];
      };
    };
  };
}