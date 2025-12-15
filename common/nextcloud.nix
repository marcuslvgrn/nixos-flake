{ config, pkgs, lib, ... }:

{

  networking.hosts = {
    "127.0.0.1" = ["mlnextcloud.dynv6.net" "mlcollabora.dynv6.net"];
    "::1" = ["mlnextcloud.dynv6.net" "mlcollabora.dynv6.net"];
  };
  
  services.collabora-online = {
    enable = true;
    port = 9980; # default
    settings = {
      # Rely on reverse proxy for SSL
      ssl = {
        enable = false;
        termination = true;
      };
      
      # Listen on loopback interface only, and accept requests from ::1
      net = {
        listen = "loopback";
        post_allow.host = ["::1"];
      };
      
      # Restrict loading documents from WOPI Host nextcloud.example.com
      storage.wopi = {
        "@allow" = true;
        host = ["mlnextcloud.dynv6.net"];
      };
      
      # Set FQDN of server
      server_name = "mlcollabora.dynv6.net";
    };
  };

  systemd.services.nextcloud-config-collabora = let
    inherit (config.services.nextcloud) occ;
    
    wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
    public_wopi_url = "https://mlcollabora.dynv6.net";
    wopi_allowlist = lib.concatStringsSep "," [
      "127.0.0.1"
      "::1"
    ];
  in {
    wantedBy = ["multi-user.target"];
    after = ["nextcloud-setup.service" "coolwsd.service"];
    requires = ["coolwsd.service"];
    script = ''
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
      ${occ}/bin/nextcloud-occ richdocuments:setup
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
  
  #setup nginx to serve

  services.nginx.virtualHosts."mlcollabora.dynv6.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true; # collabora uses websockets
    };
  };
  
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
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit richdocuments news contacts calendar tasks;
    };
    extraAppsEnable = true;
    https = true;
    hostName = "mlnextcloud.dynv6.net";
    configureRedis = true;
    database.createLocally = true;
    datadir = "/var/lib/nextcloud";
    settings = let
      prot = "https"; # or https
      host = "mlnextcloud.dynv6.net";
      dir = "/nextcloud";
    in {
      appstoreenabled = true;
      overwriteprotocol = prot;
      overwritehost = host;
      #overwritewebroot = dir;
      #overwrite.cli.url = "${prot}://${host}${dir}/";
      #htaccess.RewriteBase = dir;
      # Two apps folders
#      apps_paths = [
#        # Nix-managed apps (read-only)
#        {
#          path = "${pkgs.nextcloud32}/apps";
#          url = "/apps";
#          writable = false;
#        }
#        # Custom apps (writable)
#        {
#          path = "/var/lib/nextcloud/custom-apps";
#          url = "/custom-apps";
#          writable = true;
#        }
#      ];
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
