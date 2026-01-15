{ config, pkgs, lib, ... }:

let
  # MuhRO Patcher script
  muhroLibs = with pkgs; [
    webkitgtk_4_1
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
    # NVIDIA PRIME offload for dedicated GPU
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"

    # GTK/WebKit configuration
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
  # ===== GAMING CONFIGURATION =====

  home.packages = with pkgs; [
    # Gaming & Wine
    (lutris.override {
      extraPkgs = pkgs: [
        pkgs.libnghttp2
        pkgs.winetricks
      ];
    })
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

    # XWayland support
    xwayland-satellite

    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers

    # System & Networking for games
    samba
    krb5
    gvfs
    gnome-keyring
    seahorse
  ];

  # Environment variables
  home.sessionVariables = {
    # Wine/Lutris configuration for better game compatibility
    WINEARCH = "win32";  # Force 32-bit Wine prefixes for legacy games
  };

  # Desktop entries for games
  xdg.dataFile."icons/hicolor/512x512/apps/anarchy-online.png".source = ../../icons/anarchy-online.png;
  xdg.dataFile."icons/hicolor/512x512/apps/muhro.png".source = ../../icons/muhro.png;

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
}
