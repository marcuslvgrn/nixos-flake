{ config, lib, pkgs, pkgs-stable, pkgs-unstable, inputs, ... }:

{
  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  services = {
    # Enable GNOME
    desktopManager.gnome.enable = true;
    # Enable GDM
    displayManager.gdm.enable = true;
    # GNOME shell host connector
    gnome.gnome-browser-connector.enable = true;
  };
  services.xserver = {
    enable = true;
    xkb.layout = "se";
  };
  

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

    ])
    ++
    (with pkgs-unstable; [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-top-bar
      gnomeExtensions.appindicator
      gnomeExtensions.hibernate-status-button
      gnome-tweaks
      gnome-boxes
      linssid
      vlc
      gparted
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
