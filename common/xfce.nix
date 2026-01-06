{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let cfg = config.flakecfg.desktop.desktopManagers.xfce;
in with lib; {
  config = mkIf cfg.enable {
    flakecfg.desktop.enable = true;
    imports = [
      #Common desktop manager settings
      ./desktopManager.nix
    ];

    programs.nm-applet.enable = true;

    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = true;
    };

    environment.systemPackages = (with pkgs; [ linssid vlc gparted ])
      ++ (with pkgs-stable;
        [

        ]) ++ (with pkgs-unstable;
          [

          ]);

  };
}
