{ config, pkgs, lib, ... }:
let
  
in with lib; {
  config = mkIf config.services.printing.enable {
    services.printing = {
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
  };
}
