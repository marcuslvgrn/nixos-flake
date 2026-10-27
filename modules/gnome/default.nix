{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.gnome;
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
  packageSet = packageChannel.forChannel cfg.packageChannel;
  userData = import ../../common/users/userData.nix;
in
{
  # Selects the channel for GNOME packages and extensions as a group.
  options.gnome.packageChannel = lib.mkOption {
    type = packageChannel.type;
    default = "default";
    description = "Nixpkgs channel to use for GNOME packages and extensions.";
  };

  config = lib.mkIf config.services.desktopManager.gnome.enable {
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
      with packageSet;
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
    );

    environment.systemPackages = (
      with packageSet;
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
    );

    home-manager.users =
      lib.genAttrs
        (
          # Apply gnome extension dconf settings to all normal users on gnome hosts.
          # This belongs here rather than hardcoding a username — a NixOS module
          # should not reference specific users directly.
          lib.filter (u: (userData.users.${u}.normalUser or false)) (config.userNames or [ ])
        )
        (username: {
          dconf = lib.mkIf config.services.desktopManager.gnome.enable {
            enable = true;
            settings."org/gnome/shell" = {
              disable-user-extensions = false;
              enabled-extensions = with packageSet.gnomeExtensions; [
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
