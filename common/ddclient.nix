{ inputs, config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:
{
  services.ddclient = {
    enable = true;
    domains = [
      "mlgeegnomer.dynv6.net"
      "mlmysql.dynv6.net"
      "mlowncloud.dynv6.net"
      "mlpihole.dynv6.net"
      "mlplex.dynv6.net"
      "mlportainer.dynv6.net"
      "mlproxmox.dynv6.net"
      "mlrouter.dynv6.net"
      "mlsubsonic.dynv6.net"
      "mlsynology.dynv6.net"
      "mlbitwarden.dynv6.net"
      "mlampache.dynv6.net"
      "mldrupal.dynv6.net"
      "mlwebmin.dynv6.net"
      "mlmodem.dynv6.net"
      "mlrustdesk.dynv6.net"
    ];
    usev6 = "";
    protocol = "dyndns2";
    passwordFile = config.sops.secrets."ddclient-pass".path;
    server = "dynv6.com";
#    verbose = true;
  };
}
