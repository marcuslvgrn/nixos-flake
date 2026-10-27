{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.nextcloud-client;
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
in
{
  options.nextcloud-client = {
    enable = lib.mkEnableOption "Enable the nextcloud-client module";
    # "default" follows this host's defaultPkgChannel; stable/unstable override it.
    packageChannel = lib.mkOption {
      type = packageChannel.type;
      default = "default";
      description = "Nixpkgs channel to use for the Nextcloud client package.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (packageChannel.forChannel cfg.packageChannel).nextcloud-client
    ];
  };
}
