{ config, pkgs, lib, inputs, ... }:

let
  # MuhRO Patcher script
  muhroLibs = with pkgs; [
    webkitgtk_4_0
    gtk3
    glib
    glib-networking
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
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    cd /home/jasonk/Dot_Files/MuhRO
    exec ./Muh_Patcher "$@"
  '';

  anarchyOnlineLauncher = pkgs.writeShellScriptBin "anarchy-online-launch" ''
    cd "/home/jasonk/Games/anarchy-online/drive_c/Funcom/Anarchy Online"
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    export WINEPREFIX="/home/jasonk/Games/anarchy-online"
    exec wine Anarchy.exe "$@"
  '';
in
{
  # ===== IMPORTS =====
  imports = [
    ./modules/caelestia.nix
    ./modules/zen-browser.nix
  ];

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

    # === Note taking ===
    anytype

    # === Programming Languages ===
    # Elixir and Erlang
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang

    # === Gaming & Wine ===
    lutris
    wineWowPackages.stable
    winetricks
    muhroPatcher
    anarchyOnlineLauncher

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

    # === File Manager Support (GVFS) ===
    gvfs              # Virtual filesystem support for Thunar

    # === Keyring ===
    gnome-keyring
    seahorse

    # === Caelestia Shell & Applications ===
    # Core Caelestia apps
    xfce.thunar            # File manager
    xfce.thunar-volman     # Thunar volume manager
    xfce.tumbler           # Thumbnail generator for Thunar
    foot                   # Terminal
    fuzzel                 # Application launcher

    # Caelestia utilities
    fastfetch        # System info
    btop             # System monitor
    cliphist         # Clipboard manager
    eza              # Modern ls replacement
    hyprpicker       # Color picker
    grim             # Screenshot tool
    slurp            # Region selector
    swappy           # Screenshot editor

    # Caelestia shell dependencies
    ddcutil
    brightnessctl
    libcava
    networkmanager
    lm_sensors
    fish
    aubio
    pipewire
    material-symbols
    nerd-fonts.caskaydia-cove
    libqalculate
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

  # ===== CAELESTIA APPLICATIONS =====

  # Starship prompt (Caelestia default)
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Fastfetch system info
  programs.fastfetch = {
    enable = true;
  };

  # BTop system monitor
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
    };
  };

  # Foot terminal (Caelestia default)
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "CaskaydiaCove Nerd Font:size=11";
        dpi-aware = "yes";
      };
      colors = {
        alpha = 0.95;
      };
      scrollback = {
        lines = "20000";
      };
    };
  };

  xdg.dataFile."icons/hicolor/512x512/apps/anarchy-online.png".source = ./icons/anarchy-online.png;
  xdg.dataFile."icons/hicolor/512x512/apps/muhro.png".source = ./icons/muhro.png;

  xdg.desktopEntries.anarchy-online = {
    name = "Anarchy Online";
    genericName = "MMORPG";
    comment = "Launch Anarchy Online with NVIDIA PRIME and Wine";
    exec = "anarchy-online-launch";
    terminal = false;
    icon = "anarchy-online";
    categories = [ "Game" ];
  };

  xdg.desktopEntries.muhro = {
    name = "MuhRO Patcher";
    genericName = "Ragnarok Online Patcher";
    comment = "Launch MuhRO patcher with required GTK environment";
    exec = "muhro-patcher";
    terminal = false;
    icon = "muhro";
    categories = [ "Game" ];
  };

  xdg.desktopEntries.anarchy-online-item-assistant = {
    name = "Anarchy Online Item Assistant";
    genericName = "Item Assistant";
    comment = "Launch the AO Item Assistant helper tool";
    exec = ''
      env WINEPREFIX=/home/jasonk/Games/anarchy-online wine "/home/jasonk/Games/anarchy-online/drive_c/Program Files/AO Item Assistant+/ItemAssistant.exe"
    '';
    terminal = false;
    icon = "anarchy-online";
    categories = [ "Utility" "Game" ];
  };

  # ===== SHELL CONFIGURATION =====

  # Fish shell configuration (Caelestia default)
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      ls = "eza";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
      update = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
    };
    shellInit = ''
      # Disable fish greeting
      set -g fish_greeting
    '';
  };

  # Bash configuration (keep as fallback)
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
      update = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
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
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # ===== HYPRLAND CONFIGURATION =====
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;

    settings = {
      # Monitor configuration
      monitor = ",preferred,auto,1";

      # Autostart
      exec-once = [
        "gnome-keyring-daemon --start --components=secrets,ssh"
        "caelestia resizer -d"
        "caelestia shell -d"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "GDK_BACKEND,wayland,x11"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "DISPLAY,:0"
        "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/keyring/ssh"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Misc - Disable screen timeout/blanking
      misc = {
        disable_autoreload = false;
        force_default_wallpaper = 0;
        vfr = true;
        vrr = 0;
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = false;
      };

      # Keybindings
      "$mod" = "SUPER";
      bind = [
        # Caelestia default apps
        "$mod, T, exec, foot"                                          # Terminal
        "$mod, E, exec, thunar"                                        # File manager
        "$mod, R, exec, fuzzel"                                        # App launcher

        # Additional apps
        "$mod, A, exec, anytype"                                       # Note taking
        "$mod, S, exec, GDK_BACKEND=x11 SDL_VIDEODRIVER=x11 steam"   # Gaming

        # Window management
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshots (Caelestia utilities)
        ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"              # Screenshot region with editor
        "$mod, Print, exec, grim - | swappy -f -"                          # Screenshot full screen
        "$mod SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"        # Screenshot region to clipboard
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
