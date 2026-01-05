{ config, pkgs, lib, ... }:
let
  cfg = config.flakecfg.nginx;
  # Define all your domains and backend services here 👇
  proxyHosts = {
    "mlmodem.dynv6.net" = {
      target = "http://192.168.0.1";
      recommendedProxySettings = false;
      recommendedTlsSettings = true;
#      locationPath = "/modem/";
    };
    "mlrouter.dynv6.net" = {
      target = "http://192.168.0.2:80";
      recommendedProxySettings = true;
      recommendedTlsSettings = false;
#      locationPath = "/router/";
    };
    "mlproxmox.dynv6.net" = {
      target = "https://192.168.0.10:8006";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
#      locationPath = "/airsonic/";
    };
  };

  # Helper to create vhost definitions from proxyHosts
  mkVhost = host: proxyCfg:
    let
      loc = proxyCfg.locationPath or "/";
    in
      {
        enableACME = true;
        forceSSL = true;
        serverName = host;
        extraConfig = lib.optionalString (proxyCfg.recommendedTlsSettings or false) ''
          # Recommended TLS settings (copied from NixOS module)
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_prefer_server_ciphers on;
          ssl_session_timeout 1d;
          ssl_session_cache shared:SSL:10m;
          ssl_session_tickets off;
        '';

        locations = {
          "${loc}" = {
            proxyPass = proxyCfg.target;
            extraConfig = ''
              ${lib.optionalString (proxyCfg.recommendedProxySettings or false) ''
                # Recommended proxy settings (copied from NixOS module)
                proxy_redirect          off;
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;
                proxy_set_header        X-Forwarded-Host $host;
                proxy_set_header        X-Forwarded-Port $server_port;
              ''}
            ${proxyCfg.extraConfig or ""}
          '';
#    # proxyWebsockets = true; # uncomment if needed
          };
        };
      };
in with lib;
{
  config = mkIf cfg.enable {
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
    
    services = {
      nginx.enable = true;
      ddclient.domains = [
        "mldrupal.dynv6.net"
        "mlgeegnomer.dynv6.net"
        "mlmodem.dynv6.net"
        "mlplex.dynv6.net"
        "mlportainer.dynv6.net"
        "mlproxmox.dynv6.net"
        "mlrouter.dynv6.net"
        "mlrustdesk.dynv6.net"
        "mlsynology.dynv6.net"
        "mlwebmin.dynv6.net"
      ];
      nginx = {
        #recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        virtualHosts = {
        }
        //
        lib.mapAttrs mkVhost proxyHosts; # add all proxied HTTPS vhosts
      };
    };
  };
}
