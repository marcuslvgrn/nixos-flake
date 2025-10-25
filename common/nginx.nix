{ config, cfgPkgs, lib, ... }:

let
  acmeDynv6Hook = cfgPkgs.writeShellScript "acme-dynv6-hook" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Read Dynv6 API token from secrets file
    TOKEN=$(cat /run/secrets/dynv6-credentials)

    # $1 = action (present|cleanup)
    # $2 = FQDN (_acme-challenge.example.com)
    # $3 = TXT value
    FQDN="$2"
    VALUE="$3"

    # Extract the zone name (e.g. example.dynv6.net)
    ZONE=$(echo "$FQDN" | sed -E 's/^_acme-challenge\.//')

    echo "Processing ACME challenge for zone: $ZONE" >&2

    case "$1" in
      present)
        curl -fsSL -X POST \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          "https://dynv6.com/api/v2/zones/$ZONE/records" \
          -d '{"name":"_acme-challenge","type":"TXT","data":"'"$VALUE"'"}'
        ;;
      cleanup)
        # Optionally remove the TXT record after verification
        ;;
      *)
        echo "Unknown action: $1" >&2
        exit 1
        ;;
    esac
  '';
in
{
  networking.firewall.enable = false;

  security.acme = {
    acceptTerms = true;
    defaults.email = "marcuslvgrn@gmail.com";
    certs."mlowncloud2.dynv6.net" = {
      #might be supported in the future, then the custom hook can go away
      #dnsProvider = "dynv6";
      #webroot = null;

      #instead use this for now:
      dnsResolver = acmeDynv6Hook;
      group = "nginx";
    };
    certs."mlbitwarden2.dynv6.net" = {
      #might be supported in the future, then the custom hook can go away
      #dnsProvider = "dynv6";
      #webroot = null;

      #instead use this for now:
      dnsResolver = acmeDynv6Hook;
      group = "nginx";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "http-redirect" = {
        listen = [ { addr = "0.0.0.0"; port = 80; } ];
        serverName = "_";  # catch-all
        locations."/" = {
          return = "301 https://$host$request_uri";
        };
      };
      "mlbitwarden2.dynv6.net" =  {
        enableACME = true;
        forceSSL = true;
        #        root = "/var/www/empty";
        locations = {
          "/" = {
            proxyPass = "http://192.168.0.117:8222";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig = ''
              # required when the target is also TLS server with multiple hosts
              proxy_ssl_server_name on;
              # required when the server wants to use HTTP Authentication
              proxy_pass_header Authorization;
            '';
          };
        };
      };
      "mlowncloud2.dynv6.net" =  {
        enableACME = true;
        forceSSL = true;
        # use this root when aquiring ACME cert
        #        root = "/var/www/empty";
        locations = {
          "/" = {
            proxyPass = "http://192.168.0.117:81";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig = ''
              # required when the target is also TLS server with multiple hosts
              proxy_ssl_server_name on;
              # required when the server wants to use HTTP Authentication
              proxy_pass_header Authorization;
            '';
          };
        };
      };
#      "mlpihole.dynv6.net" =  {
#        enableACME = true;
#        forceSSL = true;
#        locations = {
#          "/" = {
#            proxyPass = "http://192.168.0.6:5380";
#          };
#        };
#      };
    };
  };
  # Ensure the webroot path exists and is readable by nginx
  systemd.tmpfiles.rules = [
    "d /var/www/empty 0755 root nginx -"
  ];
}
