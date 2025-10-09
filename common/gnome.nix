{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

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
  environment.gnome.excludePackages =
    (with pkgs; [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      gnome-text-editor
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ])
    ++
    (with pkgs-unstable; [
      
    ]);
  
  environment.systemPackages =
    (with pkgs; [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-top-bar
      gnomeExtensions.appindicator
      gnomeExtensions.hibernate-status-button
      gnome-tweaks
      gnome-boxes
      linssid
      vlc
      gparted
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

  home-manager.users.lovgren.dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions;
        [ dash-to-dock.extensionUuid
          appindicator.extensionUuid
          hide-top-bar.extensionUuid
          hibernate-status-button.extensionUuid
        ];
    };
  };
  
}
