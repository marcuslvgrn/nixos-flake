{
  config,
  #  pkgs,
  lib,
  ...
}:
let
  cfg = config.nginxExternal;

  # Helper to build a vhost definition from a proxyHosts entry.
  mkVhost =
    host: proxyCfg:
    let
      loc = proxyCfg.locationPath or "/";
    in
    {
      enableACME = true;
      forceSSL = true;
      serverName = host;
      extraConfig = lib.optionalString (proxyCfg.recommendedTlsSettings or false) ''
        # Recommended TLS settings
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
              # Recommended proxy settings
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
          proxyWebsockets = proxyCfg.proxyWebsockets;
        };
      };
    };

  # Submodule type for a single proxy host entry.
  proxyHostOpts = lib.types.submodule {
    options = {
      target = lib.mkOption {
        type = lib.types.str;
        description = "Backend URL to proxy to, e.g. http://192.168.0.1";
      };
      recommendedProxySettings = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Add standard proxy headers (Host, X-Real-IP, etc.)";
      };
      recommendedTlsSettings = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Add recommended TLS settings to the vhost";
      };
      locationPath = lib.mkOption {
        type = lib.types.str;
        default = "/";
        description = "Location path to proxy";
      };
      proxyWebsockets = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WebSocket proxying for this host";
      };
      extraConfig = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Extra nginx location config";
      };
    };
  };
in
with lib;
{
  options = {
    nginxExternal = {
      enable = mkEnableOption "Enable nginx reverse proxy for external hosts";

      # Map of public hostname → proxy target and settings.
      # Define this in the host config, not here.
      proxyHosts = mkOption {
        type = types.attrsOf proxyHostOpts;
        default = { };
        description = "Attrset of public hostnames to proxy. Keys are hostnames, values are proxy settings.";
        example = {
          "myhost.example.com" = {
            target = "http://192.168.0.1";
            recommendedProxySettings = true;
            recommendedTlsSettings = true;
          };
        };
      };

      # Additional domains to register with ddclient that are not in proxyHosts
      # (e.g. services proxied elsewhere, like Plex, Portainer, Synology).
      extraDdclientDomains = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra domains to register with ddclient beyond those in proxyHosts.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      # Generate ACME certs for all proxy hosts automatically.
      certs = lib.genAttrs (builtins.attrNames cfg.proxyHosts) (_: { });
    };

    services = {
      # Register all proxy hostnames + any extra ones with ddclient.
      ddclient.domains = (builtins.attrNames cfg.proxyHosts) ++ cfg.extraDdclientDomains;

      nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        virtualHosts = lib.mapAttrs mkVhost cfg.proxyHosts;
      };
    };
  };
}
