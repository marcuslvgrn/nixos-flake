{ config, pkgs, lib, ... }:
let
  
in with lib; {
  config = mkIf config.services.iperf3.enable {
    networking.firewall.allowedTCPPorts = [ config.services.iperf3.port ];
  };
}
