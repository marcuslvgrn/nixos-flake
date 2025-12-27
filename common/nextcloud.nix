{ config, pkgs, pkgs-stable, pkgs-unstable, lib, ... }:

{
  #Packages only installed on this host
  environment.systemPackages =
    (with pkgs; [
      chromium
      corefonts
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [

    ]);

  
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

  services.nextcloud-whiteboard-server = {
    enable = true;
    secrets = [ config.sops.secrets."nextcloud-whiteboard-secrets".path ];
    settings = {
      NEXTCLOUD_URL = "https://mlnextcloud.dynv6.org";
      CHROME_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
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
#    extraConfig = ''
#   # Remove headers injected by Nextcloud/nginx defaults
#    more_clear_headers X-Robots-Tag;
#    more_clear_headers X-Permitted-Cross-Domain-Policies;
#    more_clear_headers Referrer-Policy;
#    more_clear_headers Strict-Transport-Security;
#
#    # Add EXACT values expected by Nextcloud
#    add_header X-Robots-Tag "noindex,nofollow" always;
#    add_header X-Permitted-Cross-Domain-Policies "none" always;
#    add_header Referrer-Policy "no-referrer" always;
#    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
#    '';
#    locations."~ \\.php$".extraConfig = lib.mkAfter ''
#        more_clear_headers X-Robots-Tag;
#        more_clear_headers X-Permitted-Cross-Domain-Policies;
#        more_clear_headers Referrer-Policy;
#        more_clear_headers Strict-Transport-Security;
#        
#        add_header X-Robots-Tag "noindex,nofollow" always;
#        add_header X-Permitted-Cross-Domain-Policies "none" always;
#        add_header Referrer-Policy "no-referrer" always;
#        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
#      '';
#  locations."/" = {
#    extraConfig = ''
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto $scheme;
#        proxy_set_header X-Forwarded-Host $host;
#        proxy_set_header X-Forwarded-Server $hostname;
##        proxy_http_version 1.1;
##       add_header Referrer-Policy "no-referrer" always;
##      add_header X-Content-Type-Options "nosniff" always;
##      add_header X-Download-Options "noopen" always;
##      add_header X-Frame-Options "SAMEORIGIN" always;
##      add_header X-Permitted-Cross-Domain-Policies "none" always;
##      add_header X-XSS-Protection "1; mode=block" always;
#    '';
#    };
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
    secretFile = config.sops.secrets."nextcloud-secrets".path;
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
      maintenance_window_start = 22;
      default_phone_region = "SE";
      appstoreenabled = true;
      overwriteprotocol = prot;
      overwritehost = host;
      mail_domain = "gmail.com";
      mail_from_address = "marcuslvgrn";
      mail_smtphost = "smtp.gmail.com";
      mail_smtpport = 465;
      mail_smtpname = "marcuslvgrn@gmail.com";
      mail_smtpsecure = "ssl";
      mail_smtpauth = true;
      #};
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

    phpOptions = {
      "opcache.interned_strings_buffer" = "23";
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
