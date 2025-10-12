{ config, lib, pkgs, ... }:

{
  # ===== POWER MANAGEMENT =====

  # Enable UPower for battery monitoring
  services.upower.enable = true;

  # Enable power-profiles-daemon for power profile management
  services.power-profiles-daemon.enable = true;

  # Logind settings - prevent automatic sleep/suspend
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
    IdleAction = "ignore";
  };

  # Disable NixOS power management
  powerManagement = {
    enable = false;
  };
}
