{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
{
  services.ddclient = {
    enable = true;
    quiet = true;
    domains = [
      "mlairsonic.dynv6.net"
      "mlcollabora.dynv6.net"
      "mldrupal.dynv6.net"
      "mlgeegnomer.dynv6.net"
      "mlmodem.dynv6.net"
      "mlnextcloud.dynv6.net"
      "mlplex.dynv6.net"
      "mlportainer.dynv6.net"
      "mlproxmox.dynv6.net"
      "mlrouter.dynv6.net"
      "mlrustdesk.dynv6.net"
      "mlsynology.dynv6.net"
      "mltechnitium.dynv6.net"
      "mlvaultwarden.dynv6.net"
      "mlwebmin.dynv6.net"
    ];
    usev6 = "";
    protocol = "dyndns2";
    passwordFile = config.sops.secrets."ddclient-pass".path;
    server = "dynv6.com";
    username = "none";
    interval = "30min";
    #    verbose = true;
  };
}
