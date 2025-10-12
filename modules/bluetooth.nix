{ config, lib, pkgs, ... }:

{
  # ===== BLUETOOTH =====

  # Enable Bluetooth hardware and services
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
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
