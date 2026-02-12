{
  config,
#  pkgs,
  lib,
  ...
}:
with lib;
let
  wolEnabled = any (iface: iface.wakeOnLan.enable or false) (attrValues config.networking.interfaces);
in
{
  config = mkIf wolEnabled {
    networking.firewall.allowedUDPPorts = [ 9 ];
  };
}
