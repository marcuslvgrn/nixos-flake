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
    environment.systemPackages =
      (with pkgs; [
        deskflow
      ])
      #      ++ (with pkgs-stable; [])
      #      ++ (with pkgs-unstable; [])
      # Uncomment either block above to pin specific packages to stable or unstable
      # regardless of the host's isStable setting (see technitium for an example).
      ;

    networking.firewall = {
      allowedTCPPorts = [ 24800 ];
      allowedUDPPorts = [ 24800 ];
    };
  };
}
