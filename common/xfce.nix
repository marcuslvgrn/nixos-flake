{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  #Use network manager for xfce
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # Enable GNOME and GDM
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
    xkb.layout = "se";
  };
}
