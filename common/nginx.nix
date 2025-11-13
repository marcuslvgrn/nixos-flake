{ config, cfgPkgs, lib, ... }:
let
  # Define all your domains and backend services here 👇
#    "mlowncloud2.dynv6.net"  = "http://192.168.0.117:81";
  proxyHosts = {
    "mlbitwarden2.dynv6.net" = {
      target = "http://192.168.0.117:8222";
    };
    "mlpihole2.dynv6.net" = {
      target = "http://192.168.0.117:5380";
    };
    "mlairsonic.dynv6.net" = {
      target = "http://192.168.0.117:4040";
    };
  };

  # Helper to create vhost definitions from proxyHosts
  mkVhost = host: cfg: {
    enableACME = true;
    forceSSL = true;
    serverName = host;
    locations."/" = {
      proxyPass = cfg.target;
      extraConfig = (cfg.extraConfig or "");
#    # proxyWebsockets = true; # uncomment if needed
    };
  };
in
{
  networking.firewall.enable = false;

  security.acme = {
    acceptTerms = true;
    defaults.email = "marcuslvgrn@gmail.com";
    # Generate ACME certs for all hosts automatically
    certs = lib.genAttrs (builtins.attrNames proxyHosts) (domain: {
      webroot = "/var/lib/acme/acme-challenge";
    });
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "_" = {
        listen = [{ addr = "0.0.0.0"; port = 80; }];
        locations = {
          "/.well-known/acme-challenge/" = {
            root = "/var/lib/acme/acme-challenge";
          };
          "/" = {
            return = "301 https://$host$request_uri";
          };
        };
      };
    }
    //
    lib.mapAttrs mkVhost proxyHosts; # add all proxied HTTPS vhosts
  };
}
