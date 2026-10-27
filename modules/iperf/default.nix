{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.services.iperf3.enable {
    networking.firewall.allowedTCPPorts = [ config.services.iperf3.port ];
    networking.firewall.allowedUDPPorts = [ config.services.iperf3.port ];
  };
}
