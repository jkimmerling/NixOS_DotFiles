{ config, lib, pkgs, ... }:

{
  # ===== BLUETOOTH =====

  # Load UHID kernel module for Bluetooth HID devices (mice, keyboards)
  boot.kernelModules = [ "uhid" ];

  # Enable Bluetooth hardware and services
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        KernelExperimental = true;
      };
    };
  };

  # Enable Blueman GUI manager
  services.blueman.enable = true;

  # Unblock Bluetooth on boot (fixes rfkill soft block)
  systemd.services.unblock-bluetooth = {
    description = "Unblock Bluetooth";
    after = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
      RemainAfterExit = true;
    };
  };
}
