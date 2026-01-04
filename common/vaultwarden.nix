{ config, pkgs, lib, ... }:
let
  cfg = config.services.vaultwardenNginx;
  vaultwardenCfg = config.services.vaultwarden.config;
in with lib; {
  options.services.vaultwardenNginx = {
    enable = mkEnableOption "Vaultwarden behind Nginx with ACME";
    hostName = mkOption {
      type = types.str;
      description = "Public hostname for nginx";
    };
    contextPath = mkOption {
      type = types.str;
      default = "/";
#      default = "/vaultwarden/";
      description = "Context path for nginx";
    };
  };
  
  config = mkIf cfg.enable {
    services = {

      ddclient.domains = [
        "${cfg.hostName}"
      ];
      
      vaultwarden = {
        enable = true;
        #does not setup ACME correctly
        configureNginx = false;
        #running sqlite for now
        configurePostgres = false;
        backupDir = "/var/local/vaultwarden/backup";
        # in order to avoid having  ADMIN_TOKEN in the nix store it can be also set with the help of an environment file
        # be aware that this file must be created by hand (or via secrets management like sops)
        # NOTE: sops contains the hashed token. when logging in to admin page at <domain>/admin, use the plain text password
        environmentFile = config.sops.secrets."vaultwarden-env".path;
        config = {
          DOMAIN = "https://${cfg.hostName}${cfg.contextPath}";
          # NOTE: add users from <domain>/#/register page
          SIGNUPS_ALLOWED = false;
          
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8222;
          ROCKET_LOG = "critical";
          
          SMTP_HOST = "smtp.gmail.com";
          SMTP_PORT = 587;
          SMTP_USERNAME = "marcuslvgrn@gmail.com";
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "marcuslvgrn@gmail.com";
          SMTP_FROM_NAME = "${cfg.hostName} Bitwarden server";
        };
      };
      nginx = {
        virtualHosts.${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "${cfg.contextPath}" = {
              proxyPass = "http://127.0.0.1:${toString vaultwardenCfg.ROCKET_PORT}";
            };
            "= ${cfg.contextPath}notifications/anonymous-hub" = {
              proxyPass = "http://127.0.0.1:${toString vaultwardenCfg.ROCKET_PORT}";
              proxyWebsockets = true;
            };
            "= ${cfg.contextPath}/notifications/hub" = {
              proxyPass = "http://127.0.0.1:${toString vaultwardenCfg.ROCKET_PORT}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
