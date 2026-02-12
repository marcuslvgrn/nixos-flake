{
#  inputs,
  config,
  lib,
#  pkgs,
#  pkgs-stable,
#  pkgs-unstable,
  ...
}:
let
  serviceCfg = config.services.ddclient;
in
with lib;
{
  services.ddclient = mkIf serviceCfg.enable {
    quiet = true;
    usev6 = "";
    protocol = "dyndns2";
    passwordFile = config.sops.secrets."ddclient-pass".path;
    server = "dynv6.com";
    username = "none";
    interval = "30min";
  };
  assertions = [
    {
      assertion = serviceCfg.domains != [ ];
    }
  ];
}
