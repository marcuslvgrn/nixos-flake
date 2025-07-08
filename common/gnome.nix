{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  # Enable GNOME and GDM
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb.layout = "se";
  };
  
  # GNOME shell host connector
  services.gnome.gnome-browser-connector.enable = true;

  # Exclude some packages
  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gedit # text editor
    gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ]);

#  home-manager.users.lovgren.home = {
#    packages = with pkgs; [
#    ];
#  };
  
  environment.systemPackages = with pkgs; [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-top-bar
      gnomeExtensions.appindicator
      gnome-tweaks
      linssid
    ];
}
