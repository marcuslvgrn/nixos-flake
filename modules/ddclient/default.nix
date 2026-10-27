{
  config,
  lib,
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

  # Secret needed by ddclient — declared here so it is only decrypted
  # on hosts that actually enable ddclient.
  sops.secrets."ddclient-pass" = mkIf serviceCfg.enable { };
  assertions = [
    {
      assertion = !serviceCfg.enable || serviceCfg.domains != [ ];
      message = "services.ddclient.domains must contain at least one domain when ddclient is enabled.";
    }
  ];
}
