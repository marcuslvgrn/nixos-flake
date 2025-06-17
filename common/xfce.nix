{ config, lib, pkgs, modulesPath, ... }:

{

  #Use network manager for xfce
  networking.networkmanager.enable = true;
  programs.nm-applet = true;

  # Enable GNOME and GDM
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
    xkb.layout = "se";
  };
}
