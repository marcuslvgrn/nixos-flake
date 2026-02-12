{
  config,
  lib,
  pkgs,
#  pkgs-stable,
#  pkgs-unstable,
  ...
}:
let

in
with lib;
{
  config = mkIf config.services.xserver.desktopManager.xfce.enable {

    programs.nm-applet.enable = true;

    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
    };

    environment.systemPackages =
      (with pkgs; [
        linssid
        vlc
        gparted
      ])
#      ++ (with pkgs-stable; [])
#      ++ (with pkgs-unstable; [])
      ;

  };
}
