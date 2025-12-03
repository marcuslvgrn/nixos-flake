{ config, pkgs, lib, ... }:
let
  # Define all your domains and backend services here 👇
  proxyHosts = {
    "mlmodem.dynv6.net" = {
      target = "http://192.168.0.1";
      recommendedProxySettings = false;
      recommendedTlsSettings = true;
#      locationPath = "/modem/";
    };
    "mlrouter.dynv6.net" = {
      target = "http://192.168.0.2:8080";
      recommendedProxySettings = true;
      recommendedTlsSettings = false;
#      locationPath = "/router/";
    };
    "mlvaultwarden.dynv6.net" = {
      target = "http://192.168.0.7:8222";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
#      locationPath = "/bitwarden/";
    };
    "mltechnitium.dynv6.net" = {
      target = "http://192.168.0.7:5380";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
#      locationPath = "/pihole/";
    };
    "mlairsonic.dynv6.net" = {
      target = "http://192.168.0.7:4040";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
#      locationPath = "/airsonic/";
    };
    "mlproxmox.dynv6.net" = {
      target = "http://192.168.0.10:8006";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
#      locationPath = "/airsonic/";
    };
  };

  # Helper to create vhost definitions from proxyHosts
  mkVhost = host: cfg:
    let
      loc = cfg.locationPath or "/";
    in
      {
        enableACME = true;
        forceSSL = true;
        serverName = host;
        extraConfig = lib.optionalString (cfg.recommendedTlsSettings or false) ''
          # Recommended TLS settings (copied from NixOS module)
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_prefer_server_ciphers on;
          ssl_session_timeout 1d;
          ssl_session_cache shared:SSL:10m;
          ssl_session_tickets off;
        '';

        locations = {
          "${loc}" = {
            proxyPass = cfg.target;
            extraConfig = ''
              ${lib.optionalString (cfg.recommendedProxySettings or false) ''
                # Recommended proxy settings (copied from NixOS module)
                proxy_redirect          off;
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;
                proxy_set_header        X-Forwarded-Host $host;
                proxy_set_header        X-Forwarded-Port $server_port;
              ''}
            ${cfg.extraConfig or ""}
          '';
#    # proxyWebsockets = true; # uncomment if needed
          };
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
