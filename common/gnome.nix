{ config, lib, cfg, pkgs, pkgs-stable, pkgs-unstable, ... }:

{
  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  services = let
    baseServices = {
      xserver.enable = true;
      xserver.xkb.layout = "se";
      gnome.gnome-browser-connector.enable = true;
    };
    gnomeService = if cfg.isStable then {
      xserver.desktopManager.gnome.enable = lib.mkForce true;
      xserver.displayManager.gdm.enable = true;
    } else {
      desktopManager.gnome.enable = lib.mkForce true;
      displayManager.gdm.enable = true;
    };
  in
    baseServices // gnomeService;
  
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
    (with pkgs-stable; [
      
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
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

  home-manager.users.lovgren.dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions =
        (with pkgs.gnomeExtensions;
          [ dash-to-dock.extensionUuid
            appindicator.extensionUuid
            hide-top-bar.extensionUuid
            hibernate-status-button.extensionUuid
          ])
        ++
        (with pkgs-stable.gnomeExtensions; [
          
        ])
        ++
        (with pkgs-unstable.gnomeExtensions; [
          
        ]);
    };
  };
  
}
