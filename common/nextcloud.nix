{ config, pkgs, pkgs-stable, pkgs-unstable, lib, ... }:

{
  #Nextcloud dependencies
  environment.systemPackages =
    (with pkgs; [
      chromium #dependency for whiteboard
      corefonts #dependency for office
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [

    ]);

  
  ##########################
  # Setup Nextcloud
  ##########################

  # nginx
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
    #proxy whiteboard subdir to whiteboard server on port 3002
    locations."/whiteboard/" = {
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_pass http://localhost:3002/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };

  #enable and configure service
  services.nextcloud = {
    enable = true;
    #mail_smtppassword
    secretFile = config.sops.secrets."nextcloud-secrets".path;
    #choose package
    package = pkgs.nextcloud32;
    #install apps
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit richdocuments news contacts calendar tasks cookbook mail;
    };
    extraAppsEnable = true;
    https = true;
    hostName = "mlnextcloud.dynv6.net";
    #use redis for caching
    configureRedis = true;
    database.createLocally = true;
    datadir = "/var/lib/nextcloud";
    settings = {
      maintenance_window_start = 22;
      default_phone_region = "SE";
      appstoreenabled = true;
      overwriteprotocol = "https";
      overwritehost = "mlnextcloud.dynv6.net";
      mail_domain = "gmail.com";
      mail_from_address = "marcuslvgrn";
      mail_smtphost = "smtp.gmail.com";
      mail_smtpport = 465;
      mail_smtpname = "marcuslvgrn@gmail.com";
      mail_smtpsecure = "ssl";
      mail_smtpauth = true;
    };

    #address warning in GUI
    phpOptions = {
      "opcache.interned_strings_buffer" = "23";
    };

    #enable caching
    caching.redis = true;

    #configure settings
    config = {
      # Explicit database config
      dbtype = "mysql";
      adminuser = "admin";
      #admin password
      adminpassFile = config.sops.secrets."nextcloud-admin-pass".path;
    };
  };

  ##########################
  # Setup collabora for nextcloud office
  ##########################
  
  #nginx
  services.nginx.virtualHosts."mlcollabora.dynv6.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
      proxyWebsockets = true; # collabora uses websockets
    };
  };
  #for correct allow list
  networking.hosts = {
    "127.0.0.1" = ["mlnextcloud.dynv6.net" "mlcollabora.dynv6.net"];
    "::1" = ["mlnextcloud.dynv6.net" "mlcollabora.dynv6.net"];
  };
  #enable service
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
      
      # Restrict loading documents from WOPI Host
      storage.wopi = {
        "@allow" = true;
        host = ["mlnextcloud.dynv6.net"];
      };
      
      # Set FQDN of server
      server_name = "mlcollabora.dynv6.net";
    };
  };

  #enable whiteboard server
  services.nextcloud-whiteboard-server = {
    enable = true;
    #this is a template containing a env variable JWT_SECRET_KEY set to whiteboard secret from
    #nextcloud-whiteboard-secret, which is used below to set the secret in nextcloud
    secrets = [ config.sops.templates."nextcloud-whiteboard-env".path ];
    settings = {
      NEXTCLOUD_URL = "https://mlnextcloud.dynv6.org";
      CHROME_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
    };
  };

  #setup whiteboard correctly in nextcloud
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
      JWT_SECRET="$(cat ${config.sops.secrets."nextcloud-whiteboard-secret".path})"
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
      ${occ}/bin/nextcloud-occ richdocuments:setup
      ${occ}/bin/nextcloud-occ config:app:set whiteboard collabBackendUrl --value "https://mlnextcloud.dynv6.net/whiteboard"
      ${occ}/bin/nextcloud-occ config:app:set whiteboard jwt_secret_key --value "$JWT_SECRET"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };


#  systemd.services.nextcloud-create-users = let
#    inherit (config.services.nextcloud) occ;
#  in {
#    wantedBy = ["multi-user.target"];
#    after = ["nextcloud-setup.service"];
#    requires = ["nextcloud-setup.service"];
#    script = ''
#      ${occ}/bin/nextcloud-occ user:setting admin settings email "marcuslvgrn@gmail.com"
#      ${occ}/bin/nextcloud-occ user:add --display-name="Marcus Lövgren" --group "admin" --group "users" --generate-password --email "marcuslvgrn@gmail.com" marcuslvgrn
#      ${occ}/bin/nextcloud-occ user:add --display-name="Andreas Lövgren" --group "users" --generate-password --email "marcuslvgrn@gmail.com" andreas
#    '';
#    serviceConfig = {
#      Type = "oneshot";
#    };
#  };
}
