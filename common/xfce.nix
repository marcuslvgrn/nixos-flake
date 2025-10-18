{ config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:

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

  environment.systemPackages =
    (with cfgPkgs; [
      linssid
      vlc
      gparted
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

}
