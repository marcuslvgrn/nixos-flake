{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  programs.nm-applet.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
    xkb.layout = "se";
  };

  environment.systemPackages = with pkgs; [
      linssid
      vlc
      gparted
  ];

}
