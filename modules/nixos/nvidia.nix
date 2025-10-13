{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  # ===== GRAPHICS & DISPLAY =====
  # Enable Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer

      # Mesa drivers (includes RADV for AMD)
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      vulkan-validation-layers
      mesa
    ];
  };

  # NVIDIA configuration
  hardware.nvidia = {
    # Use open source kernel modules (RTX 4070 supports this)
    open = true;

    # Modesetting is required
    modesetting.enable = true;

    # Nvidia power management (optional but recommended for laptops)
    powerManagement.enable = false; # Experimental, can cause sleep issues
    powerManagement.finegrained = false; # Turns off GPU when not in use

    # Use the NVidia open kernel module
    nvidiaSettings = true;

    # Select the driver version (use production for stability)
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # PRIME configuration for hybrid graphics
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:8:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Environment variables for Vulkan
  environment.sessionVariables = {
    # Help Vulkan loader find ICD files for both AMD and NVIDIA
    AMD_VULKAN_ICD = "RADV";  # Use RADV by default for AMD
    # Explicitly select NVIDIA's 64-bit and 32-bit Vulkan ICDs for Wine/DXVK
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
    NIXOS_OZONE_WL = "1";
  };

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Add nvidia-offload script to system packages
  environment.systemPackages = [ nvidia-offload ];
}
