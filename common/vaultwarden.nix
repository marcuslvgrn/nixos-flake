{ config, cfgPkgs, lib, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/local/vaultwarden/backup";
    # in order to avoid having  ADMIN_TOKEN in the nix store it can be also set with the help of an environment file
    # be aware that this file must be created by hand (or via secrets management like sops)
    environmentFile = config.sops.secrets."vaultwarden-env".path;
    config = {
      # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
      DOMAIN = "https://mlbitwarden2.dynv6.net";
      SIGNUPS_ALLOWED = false;

      #update to actual IP
      ROCKET_ADDRESS = "192.168.0.7";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      
      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_USERNAME = "marcuslvgrn@gmail.com";
      SMTP_SECURITY = "starttls";
      SMTP_FROM = "marcuslvgrn@gmail.com";
      SMTP_FROM_NAME = "mlbitwarden.dynv6.net Bitwarden server";
    };
  };
}
