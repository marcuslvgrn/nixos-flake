{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let cfg = config.moduleCfg.desktop.desktopManagers.gnome;
in with lib; {
  imports = [
    #Common desktop manager settings
    ./desktopManager.nix
  ];

  config = mkIf cfg.enable {
    moduleCfg.desktop.enable = true;

    services = {
      xserver.enable = true;
      gnome.gnome-browser-connector.enable = true;
      desktopManager.gnome.enable = lib.mkForce true;
      displayManager.gdm.enable = true;
    };

    # Exclude some packages
    environment.gnome.excludePackages = (with pkgs; [
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
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ]) ++ (with pkgs-stable;
      [

      ]) ++ (with pkgs-unstable;
        [

        ]);

    environment.systemPackages = (with pkgs; [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-top-bar
      gnomeExtensions.appindicator
      gnomeExtensions.power-off-options
      gnome-tweaks
      gnome-boxes
      linssid
      vlc
      gparted
      dconf2nix
      dconf-editor
    ])
    ++
    (with pkgs-stable;
      [
        
      ])
    ++
    (with pkgs-unstable;
      [
        
      ]);

    home-manager.users.lovgren.dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = (with pkgs.gnomeExtensions; [
          dash-to-dock.extensionUuid
          appindicator.extensionUuid
          hide-top-bar.extensionUuid
          hibernate-status-button.extensionUuid
        ]) ++ (with pkgs-stable.gnomeExtensions;
          [

          ]) ++ (with pkgs-unstable.gnomeExtensions;
            [

            ]);
      };
    };
  };

}
