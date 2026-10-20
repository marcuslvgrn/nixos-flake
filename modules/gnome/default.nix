{
  config,
  lib,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:
let
  userData = import ../../common/users/userData.nix;
in
with lib;
{
  imports = [

  ];

  config = mkIf config.services.desktopManager.gnome.enable {
    services.flatpak.enable = true;
    programs.firefox = {
      enable = true;
      languagePacks = [
        "sv-SE"
        "en-US"
      ];
    };

    services = {
      xserver.enable = true;
      gnome.gnome-browser-connector.enable = true;
      displayManager.gdm.enable = true;
      gnome.gnome-keyring.enable = true;
    };

    # Exclude some packages
    environment.gnome.excludePackages = (
      with pkgs;
      [
        atomix # puzzle game
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        gedit # text editor
        gnome-characters
        gnome-music
        gnome-terminal
        gnome-tour
        hitori # sudoku game
        iagno # go game
        tali # poker game
        totem # video player
        gnome-maps
        gnome-weather
        orca
        snapshot
        yelp
      ]
    )
    #    ++ (with pkgs-stable; [])
    #    ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's isStable setting (see technitium for an example).
    ;

    environment.systemPackages = (
      with pkgs;
      [
        gnomeExtensions.dash-to-dock
        gnomeExtensions.hide-top-bar
        gnomeExtensions.appindicator
        gnomeExtensions.power-off-options
        gnomeExtensions.wake-on-lan
        gnomeExtensions.no-overview
        gnome-tweaks
        vlc
        gparted
        dconf2nix
        dconf-editor
        papers
        gsettings-desktop-schemas
      ]
    )
    #    ++ (with pkgs-stable; [])
    #    ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's isStable setting (see technitium for an example).
    ;

    home-manager.users = lib.genAttrs (
      # Apply gnome extension dconf settings to all normal users on gnome hosts.
      # This belongs here rather than hardcoding a username — a NixOS module
      # should not reference specific users directly.
      lib.filter (u: (userData.users.${u}.normalUser or false)) (config.userNames or [])
    ) (username: {
      dconf = lib.mkIf config.services.desktopManager.gnome.enable {
        enable = true;
        settings."org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            dash-to-dock.extensionUuid
            appindicator.extensionUuid
            hide-top-bar.extensionUuid
            hibernate-status-button.extensionUuid
            power-off-options.extensionUuid
            wake-on-lan.extensionUuid
            no-overview.extensionUuid
          ];
        };
      };
    });
  };

}
