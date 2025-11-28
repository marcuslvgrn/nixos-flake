{ config, pkgs, lib, ... }:

{

  #setup nginx to serve
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

  ##########################
  # Ensure custom apps folder exists
  ##########################
  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud/custom-apps 0750 nextcloud nextcloud -"
  ];
  
  ##########################
  # Nextcloud setup
  ##########################
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    https = true;
    hostName = "mlowncloud2.dynv6.net";
    configureRedis = true;
    database.createLocally = true;
    datadir = "/var/lib/nextcloud";
    settings = let
      prot = "https"; # or https
      host = "mlowncloud2.dynv6.net";
      dir = "/nextcloud";
    in {
      appstoreenabled = true;
      overwriteprotocol = prot;
      overwritehost = host;
      #overwritewebroot = dir;
      #overwrite.cli.url = "${prot}://${host}${dir}/";
      #htaccess.RewriteBase = dir;
      # Two apps folders
      apps_paths = [
        # Nix-managed apps (read-only)
        {
          path = "${pkgs.nextcloud32}/apps";
          url = "/apps";
          writable = false;
        }
        # Custom apps (writable)
        {
          path = "/var/lib/nextcloud/custom-apps";
          url = "/custom-apps";
          writable = true;
        }
      ];
    };
    
    # Data directory
    caching.redis = true;
    config = {
      # Explicit database config
      dbtype = "mysql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets."nextcloud-admin-pass".path;
    };
  };
}
