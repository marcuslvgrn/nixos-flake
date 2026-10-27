{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.bitwarden-desktop;
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
  options.bitwarden-desktop = {
    enable = lib.mkEnableOption "Bitwarden Desktop";
    # "default" follows this host's defaultPkgChannel; stable/unstable override it.
    packageChannel = lib.mkOption {
      type = packageChannel.type;
      default = "default";
      description = "Nixpkgs channel to use for Bitwarden Desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (packageChannel.forChannel cfg.packageChannel).bitwarden-desktop
    ];
  };
}
