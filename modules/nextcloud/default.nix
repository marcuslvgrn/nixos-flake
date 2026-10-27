{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.nextcloud;
  serviceCfg = config.services.nextcloud;
  # Share the channel enum and package-set selection logic with other modules.
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
  # Select the channel explicitly chosen here, or fall back to the host default.
  packageSet = packageChannel.forChannel cfg.packageChannel;
  # Normalize a configured mount path so URLs and nginx locations use one form.
  nextcloudWebroot =
    if cfg.contextPath == "/" then
      ""
    else
      "/${
        lib.concatStringsSep "/" (lib.filter (part: part != "") (lib.splitString "/" cfg.contextPath))
      }";
  nextcloudLocationPrefix = if nextcloudWebroot == "" then "/" else "${nextcloudWebroot}/";
in
with lib;
{

  options = {
    nextcloud = {
      nextcloudHostName = mkOption {
        type = types.str;
        description = "Public hostname for nextcloud nginx";
      };
      collaboraHostName = mkOption {
        type = types.str;
        description = "Public hostname for collabora nginx";
      };
      contextPath = mkOption {
        type = types.str;
        default = "/";
        description = "URL path where Nextcloud is served; use / for the domain root.";
      };
      # "default" follows this host's defaultPkgChannel; stable/unstable override it.
      packageChannel = mkOption {
        type = packageChannel.type;
        default = "default";
        description = "Nixpkgs channel to use for the Nextcloud server and its apps.";
      };
    };
  };

  config = mkIf serviceCfg.enable {
    assertions = [
      {
        assertion = (cfg.nextcloudHostName != "" && cfg.collaboraHostName != "");
        message = "nextcloud.nextcloudHostName and nextcloud.collaboraHostName must both be set when Nextcloud is enabled.";
      }
      {
        assertion =
          cfg.contextPath == "/" || builtins.match "^(/[A-Za-z0-9_-]+)+/?$" cfg.contextPath != null;
        message = "nextcloud.contextPath must be / or a slash-prefixed path containing only letters, numbers, _ and -.";
      }
    ];

    # Secrets needed by this service — declared here so they are only
    # decrypted on hosts that actually run nextcloud.
    sops.secrets."nextcloud-admin-pass" = { };
    sops.secrets."nextcloud-secrets" = { };
    sops.secrets."nextcloud-whiteboard-secret" = { };

    sops.templates.nextcloud-whiteboard-env = {
      content = ''
        JWT_SECRET_KEY=${config.sops.placeholder."nextcloud-whiteboard-secret"}
      '';
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ]; # nginx; Collabora is reached through nginx on loopback

    #Nextcloud dependencies
    environment.systemPackages = with packageSet; [
      chromium # dependency for whiteboard
      corefonts # dependency for office
      ffmpeg
      nodejs
      util-linux
    ];

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

      nginx.enable = true;

      # nginx
      nginx.virtualHosts.${config.services.nextcloud.hostName} = {
        forceSSL = true;
        enableACME = true;
        #proxy whiteboard subdir to whiteboard server on port 3002
        locations = {
          # Keep Nginx's generated PHP regex locations from intercepting this proxy path.
          "^~ ${nextcloudLocationPrefix}whiteboard/" = {
            extraConfig = ''
              proxy_pass http://localhost:3002/;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $host;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };
        }
        // (lib.optionalAttrs (nextcloudWebroot != "") {
          # Nextcloud's NixOS nginx configuration serves from /. Rewrite the
          # configured URL prefix away before passing requests to that location.
          "= ${nextcloudWebroot}".return = "308 ${nextcloudLocationPrefix}$is_args$args";
          "^~ ${nextcloudLocationPrefix}".extraConfig = ''
            rewrite ^${nextcloudLocationPrefix}(.*)$ /$1 last;
          '';
        });
      };

      #enable and configure service
      nextcloud = {
        #mail_smtppassword
        secretFile = config.sops.secrets."nextcloud-secrets".path;
        #choose package
        package = packageSet.nextcloud35;
        #install apps. nonexistent apps are:
        #printer files_antivirus previewgenerator whiteboard
        #check available apps in nix repl: nixosConfigurations.nixosTranfor.config.services.nextcloud.package.packages.apps
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            richdocuments
            news
            #contacts
            calendar
            tasks
            cookbook
            mail
            bookmarks
            #memories
            music
            ;
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
          overwritewebroot = nextcloudWebroot;
          "overwrite.cli.url" = "https://${cfg.nextcloudHostName}${nextcloudWebroot}";
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
        phpOptions = {
          "opcache.interned_strings_buffer" = "23";
          "session.upload_progress.enabled" = "Off";
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
      nginx.virtualHosts."${cfg.collaboraHostName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.collabora-online.port}";
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

          # Listen on loopback interface only, and accept requests from localhost
          net = {
            listen = "loopback";
            proto = "IPv4";
            post_allow.host = [ "127.0.0.1" ];
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
          NEXTCLOUD_URL = "https://${cfg.nextcloudHostName}${nextcloudWebroot}";
          CHROME_EXECUTABLE_PATH = "/run/current-system/sw/bin/chromium";
        };
      };
    };

    #for correct allow list
    networking.hosts = {
      "127.0.0.1" = [
        "${cfg.nextcloudHostName}"
        "${cfg.collaboraHostName}"
      ];
    };
    #setup whiteboard correctly in nextcloud
    systemd.services.nextcloud-config-collabora =
      let
        inherit (config.services.nextcloud) occ;

        wopi_url = "http://127.0.0.1:${toString config.services.collabora-online.port}";
        public_wopi_url = "https://${cfg.collaboraHostName}";
        wopi_allowlist = lib.concatStringsSep "," [ "127.0.0.1" ];
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [
          "nextcloud-setup.service"
          "coolwsd.service"
        ];
        requires = [ "coolwsd.service" ];
        script = ''
          JWT_SECRET="$(cat ${config.sops.secrets."nextcloud-whiteboard-secret".path})"
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
          ${occ}/bin/nextcloud-occ richdocuments:setup
          ${occ}/bin/nextcloud-occ config:app:set whiteboard collabBackendUrl --value "https://${cfg.nextcloudHostName}${nextcloudLocationPrefix}whiteboard"
          ${occ}/bin/nextcloud-occ config:app:set whiteboard jwt_secret_key --value "$JWT_SECRET"
          ${occ}/bin/nextcloud-occ user:setting admin settings email "marcus.lovgren@proton.me"
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

    systemd.services.nextcloud-create-users =
      let
        inherit (config.services.nextcloud) occ;
      in
      {
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
        serviceConfig = {
          Type = "oneshot";
        };
      };

    systemd.services.nextcloud-settings =
      let
        inherit (config.services.nextcloud) occ;
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [ "nextcloud-setup.service" ];
        requires = [ "nextcloud-setup.service" ];
        script = ''
          ${occ}/bin/nextcloud-occ config:app:set files_antivirus av_mode --value "socket"
          ${occ}/bin/nextcloud-occ config:app:set files_antivirus av_socket --value "/run/clamav/clamd.ctl"
          ${occ}/bin/nextcloud-occ app:enable assistant
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
  };
}
