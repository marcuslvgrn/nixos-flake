{ config, cfgPkgs, lib, ... }:
let
  # Define all your domains and backend services here 👇
  proxyHosts = {
    "mlbitwarden2.dynv6.net" = "http://192.168.0.117:8222";
    "mlowncloud2.dynv6.net"  = "http://192.168.0.117:81";
    "mlpihole2.dynv6.net"    = "http://192.168.0.117:5380";
  };

  # Helper to create vhost definitions from proxyHosts
  mkVhost = host: target: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = target;
      # proxyWebsockets = true; # uncomment if needed
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
#    certs."mlowncloud2.dynv6.net" = {
#      webroot = "/var/lib/acme/acme-challenge";
#    };
#    certs."mlbitwarden2.dynv6.net" = {
#      webroot = "/var/lib/acme/acme-challenge";
#    };
#    certs."mlpihole2.dynv6.net" = {
#      webroot = "/var/lib/acme/acme-challenge";
#    };
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
#      "mlbitwarden2.dynv6.net" =  {
#        enableACME = true;
#        forceSSL = true;
#        locations = {
#          "/" = {
#            proxyPass = "http://192.168.0.117:8222";
##            proxyWebsockets = true; # needed if you need to use WebSocket
#          };
#        };
#      };
#      "mlowncloud2.dynv6.net" =  {
#        enableACME = true;
#        forceSSL = true;
#        locations = {
#          "/" = {
#            proxyPass = "http://192.168.0.117:81";
##            proxyWebsockets = true; # needed if you need to use WebSocket
#          };
#        };
#      };
#      "mlpihole2.dynv6.net" =  {
#        enableACME = true;
#        forceSSL = true;
#        locations = {
#          "/" = {
#            proxyPass = "http://192.168.0.117:5380";
##            proxyWebsockets = true;
#          };
#        };
#      };
#    };
  };
}
