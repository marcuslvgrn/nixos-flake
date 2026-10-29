{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.xfce;
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
  packageSet = packageChannel.forChannel cfg.packageChannel;
in
{
  # Selects the channel for XFCE and related packages as a group.
  options.xfce.packageChannel = lib.mkOption {
    type = packageChannel.type;
    default = "default";
    description = "Nixpkgs channel to use for XFCE and related packages.";
  };

  config = lib.mkIf config.services.xserver.desktopManager.xfce.enable {

    programs.nm-applet.enable = true;

    services = {
      xserver.enable = true;
      displayManager.sddm.enable = true;
    };

    environment.systemPackages = (
      with packageSet;
      [
        linssid
        vlc
        gparted
      ]
    );

  };
}
