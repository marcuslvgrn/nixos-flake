{ config, pkgs, pkgs-stable, pkgs-unstable, lib, ... }:
let
  cfg = config.flakecfg.nextcloud;
  nextcloudCfg = config.services.nextcloud-dns-server;
in with lib; {

  config = mkIf cfg.enable {

    #Nextcloud dependencies
    environment.systemPackages = (with pkgs; [
      chromium # dependency for whiteboard
      corefonts # dependency for office
      ffmpeg
      nodejs
      #      libtensorflow
      util-linux
    ]) ++ (with pkgs-stable;
      [

      ]) ++ (with pkgs-unstable;
        [

        ]);

    #Setup services
    services = {

      ddclient.domains = [
        "${cfg.nextcloudHostName}"
        "${cfg.collaboraHostName}"
      ];
      
      #requires setting up administration->security->antivirus to clamad daemon (socket), socket=/run/clamav/clamd.ctl in nextcloud
      clamav = {
        #    scanner.enable = true;
        #    updater.enable = true;
        daemon.enable = true;
      };

      ##########################
      # Setup Nextcloud
      ##########################

      # nginx
      nginx.virtualHosts.${config.services.nextcloud.hostName} = {
        forceSSL = true;
        enableACME = true;
        #proxy whiteboard subdir to whiteboard server on port 3002
        locations."/whiteboard/" = {
          extraConfig = ''
            proxy_pass http://localhost:3002/;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };

      #enable and configure service
      nextcloud = {
        enable = true;
        #mail_smtppassword
        secretFile = config.sops.secrets."nextcloud-secrets".path;
        #choose package
        package = pkgs.nextcloud32;
        #install apps. nonexistent apps are:
        #printer files_antivirus previewgenerator whiteboard
        #check available apps in nix repl: nixosConfigurations.nixosTranfor.config.services.nextcloud.package.packages.apps
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit richdocuments news contacts calendar tasks cookbook mail
            bookmarks memories music;
        };
        extraAppsEnable = true;
        https = true;
        hostName = "${cfg.nextcloudHostName}";
        #use redis for caching
        configureRedis = true;
        database.createLocally = true;
        datadir = "/var/lib/nextcloud";
        settings = {
          maintenance_window_start = 100;
          default_phone_region = "SE";
          appstoreenabled = true;
          overwriteprotocol = "https";
          overwritehost = "${cfg.nextcloudHostName}";
          mail_domain = "gmail.com";
          mail_from_address = "marcuslvgrn";
          mail_smtphost = "smtp.gmail.com";
          mail_smtpport = 465;
          mail_smtpname = "marcuslvgrn@gmail.com";
          mail_smtpsecure = "ssl";
          mail_smtpauth = true;
          log_type = "file";
          loglevel = 2;
          logfile = "/var/lib/nextcloud/nextcloud.log";
          trashbin_retention_obligation = "auto, 7";
        };

        #address warning in GUI
        phpOptions = { "opcache.interned_strings_buffer" = "23"; };

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
      nginx.virtualHosts."${cfg.collaboraHostName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass =
            "http://[::1]:${toString config.services.collabora-online.port}";
          proxyWebsockets = true; # collabora uses websockets
        };
      };
      #enable service
      collabora-online = {
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
            post_allow.host = [ "::1" ];
          };

          # Restrict loading documents from WOPI Host
          storage.wopi = {
            "@allow" = true;
            host = [ "${cfg.nextcloudHostName}" ];
          };

          # Set FQDN of server
          server_name = "${cfg.collaboraHostName}";
        };
      };

      #enable whiteboard server
      nextcloud-whiteboard-server = {
        enable = true;
        #this is a template containing a env variable JWT_SECRET_KEY set to whiteboard secret from
        #nextcloud-whiteboard-secret, which is used below to set the secret in nextcloud
        secrets = [ config.sops.templates."nextcloud-whiteboard-env".path ];
        settings = {
          NEXTCLOUD_URL = "https://${cfg.nextcloudHostName}";
          CHROME_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
        };
      };
    };

    #for correct allow list
    networking.hosts = {
      "127.0.0.1" = [ "${cfg.nextcloudHostName}" "${cfg.collaboraHostName}" ];
      "::1" = [ "${cfg.nextcloudHostName}" "${cfg.collaboraHostName}" ];
    };
    #setup whiteboard correctly in nextcloud
    systemd.services.nextcloud-config-collabora = let
      inherit (config.services.nextcloud) occ;

      wopi_url =
        "http://[::1]:${toString config.services.collabora-online.port}";
      public_wopi_url = "https://${cfg.collaboraHostName}";
      wopi_allowlist = lib.concatStringsSep "," [ "127.0.0.1" "::1" ];
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" "coolwsd.service" ];
      requires = [ "coolwsd.service" ];
      script = ''
        JWT_SECRET="$(cat ${
          config.sops.secrets."nextcloud-whiteboard-secret".path
        })"
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${
          lib.escapeShellArg wopi_url
        }
        ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${
          lib.escapeShellArg public_wopi_url
        }
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${
          lib.escapeShellArg wopi_allowlist
        }
        ${occ}/bin/nextcloud-occ richdocuments:setup
        ${occ}/bin/nextcloud-occ config:app:set whiteboard collabBackendUrl --value "https://${cfg.nextcloudHostName}/whiteboard"
        ${occ}/bin/nextcloud-occ config:app:set whiteboard jwt_secret_key --value "$JWT_SECRET"
        ${occ}/bin/nextcloud-occ user:setting admin settings email "marcus.lovgren@proton.me"
      '';
      serviceConfig = { Type = "oneshot"; };
    };

    systemd.services.nextcloud-create-users =
      let inherit (config.services.nextcloud) occ;
      in {
        wantedBy = [ "multi-user.target" ];
        after = [ "nextcloud-setup.service" ];
        requires = [ "nextcloud-setup.service" ];
        script = ''
          if ! ${occ}/bin/nextcloud-occ user:info marcus >/dev/null 2>&1; then
            ${occ}/bin/nextcloud-occ user:add --display-name="Marcus Lövgren" \
            --group "admin" --group "users" --generate-password --email "marcus.lovgren@proton.me" \
            marcus
          fi
          if ! ${occ}/bin/nextcloud-occ user:info andreas >/dev/null 2>&1; then
            ${occ}/bin/nextcloud-occ user:add --display-name="Andreas Lövgren" \
            --group "users" --generate-password --email "marcus.lovgren@proton.me" andreas
          fi
          if ! ${occ}/bin/nextcloud-occ user:info gerd >/dev/null 2>&1; then
            ${occ}/bin/nextcloud-occ user:add --display-name="Gerd Lövgren" \
            --group "users" --generate-password --email "marcus.lovgren@proton.me" gerd
          fi
          ${occ}/bin/nextcloud-occ user:setting admin settings email "marcus.lovgren@proton.me"
          ${occ}/bin/nextcloud-occ user:setting marcus settings email "marcus.lovgren@proton.me"
          ${occ}/bin/nextcloud-occ user:setting andreas settings email "marcus.lovgren@proton.me"
          ${occ}/bin/nextcloud-occ user:setting gerd settings email "marcus.lovgren@proton.me"
        '';
        serviceConfig = { Type = "oneshot"; };
      };

    systemd.services.nextcloud-settings =
      let inherit (config.services.nextcloud) occ;
      in {
        wantedBy = [ "multi-user.target" ];
        after = [ "nextcloud-setup.service" ];
        requires = [ "nextcloud-setup.service" ];
        script = ''
          ${occ}/bin/nextcloud-occ config:app:set files_antivirus av_mode --value "socket"
          ${occ}/bin/nextcloud-occ config:app:set files_antivirus av_socket --value "/run/clamav/clamd.ctl"
          ${occ}/bin/nextcloud-occ config:app:set files_antivirus av_socket --value "/run/clamav/clamd.ctl"
        '';
        serviceConfig = { Type = "oneshot"; };
      };
  };
}
