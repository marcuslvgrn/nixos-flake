{
  config,
  lib,
  #nixosConfig,
  pkgs,
  #pkgs-unstable,
  ...
}:
with lib;
{
  options = {
    deskflow = {
      enable = mkEnableOption "Enable deskflow";
    };
  };

  config = mkIf config.deskflow.enable {
    environment.systemPackages = with pkgs; [
      deskflow
    ];

    networking.firewall = {
      allowedTCPPorts = [ 24800 ];
      allowedUDPPorts = [ 24800 ];
    };
  };
}
