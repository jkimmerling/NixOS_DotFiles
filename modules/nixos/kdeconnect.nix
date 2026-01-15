{ config, pkgs, ... }:

{
  # ===== KDE CONNECT =====

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Open firewall ports for KDE Connect (TCP and UDP 1714-1764)
  # Restricted to WiFi interface for security
  networking.firewall.interfaces.wlp4s0 = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # Start KDE Connect indicator at boot for user session
  systemd.user.services.kdeconnect-indicator = {
    description = "KDE Connect Indicator";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
