{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.deskflow;
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
  options.deskflow = {
    enable = lib.mkEnableOption "Enable deskflow";
    # "default" follows this host's defaultPkgChannel; stable/unstable override it.
    packageChannel = lib.mkOption {
      type = packageChannel.type;
      default = "default";
      description = "Nixpkgs channel to use for the Deskflow package.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (packageChannel.forChannel cfg.packageChannel).deskflow
    ];

    networking.firewall = {
      allowedTCPPorts = [ 24800 ];
      allowedUDPPorts = [ 24800 ];
    };
  };
}
