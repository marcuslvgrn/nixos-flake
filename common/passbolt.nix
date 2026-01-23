{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.passbolt;

  phpPackage = pkgs.php.buildEnv {
      extensions = ({ enabled, all }: enabled ++ (with all; [
        curl 
        intl
        mbstring
        openssl
        pdo
        pdo_mysql
        gd
        redis
        gnupg
      ]));
  };

  #copied from installation default files
  appPhp = ./passbolt-php/app.php;
  passboltPhp = ./passbolt-php/passbolt.php;

  passboltPackage = pkgs.php.buildComposerProject2 (finalAttrs: {
    pname = "passbolt";
    version = "v5.8.0";
    
    src = pkgs.fetchFromGitHub {
      owner = "passbolt";
      repo = "passbolt_api";
      tag = finalAttrs.version;
      sha256 = "sha256-AkK/64s3nRXIZ394U4bYcnOlXPivPuviHw/6mcct11c=";
    };
    
    php = phpPackage;
    vendorHash = "sha256-aGGIJ0jUu0if6R/M7D53Ekn8qQhfOwtDGVyLeP13LME=";
    composerStrictValidation = false;

    postInstall = ''
      cfgDir=$out/share/php/passbolt/config
      install -m644 ${appPhp} "$cfgDir/app.php"
      install -m644 ${passboltPhp} "$cfgDir/passbolt.php"
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/tmp
      ${pkgs.coreutils}/bin/ln -s /var/lib/passbolt/tmp $out/share/php/passbolt/tmp
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/config/jwt
      ${pkgs.coreutils}/bin/ln -s /var/lib/passbolt/jwt $out/share/php/passbolt/config/jwt
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/config/gpg
      ${pkgs.coreutils}/bin/ln -s /var/lib/passbolt/gpg $out/share/php/passbolt/config/gpg
#      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/logs
      ${pkgs.coreutils}/bin/ln -s /var/lib/passbolt/logs $out/share/php/passbolt/logs
#      cp $cfgDir/app.default.php $cfgDir/app.php
#      cp $cfgDir/passbolt.default.php $cfgDir/passbolt.php
      echo "passboltPackage installed 1"
    '';      
  });

#  passboltApp = pkgs.symlinkJoin {
#    name = "passbolt-app";
#    
#    paths = [
#      passboltPackage
#    ];
#    
#    postBuild = ''
#      cfgDir=$out/share/php/passbolt/config
#
#      cp $cfgDir/app.default.php $cfgDir/app.php
#      cp $cfgDir/passbolt.default.php $cfgDir/passbolt.php
#  
#      # Replace only the two site-specific config files
##      rm -f $cfgDir/app.php
##      rm -f $cfgDir/app.default.php
##      rm -f $cfgDir/passbolt.php
##      ln -s /etc/passbolt/app.php $cfgDir/app.php
##      ln -s /etc/passbolt/passbolt.php $cfgDir/passbolt.php
#    '';
#  };

in {
  options.services.passbolt = {
    enable = mkEnableOption "Passbolt password manager";

    hostName = mkOption {
      type = types.str;
      example = "passbolt.example.com";
    };

    database = {
      host = mkOption { type = types.str; default = "localhost"; };
      name = mkOption { type = types.str; default = "passbolt"; };
      user = mkOption { type = types.str; default = "nginx"; };
#      passwordFile = mkOption {
#        type = types.path;
#        default = config.sops.secrets."passbolt-db-pass".path;
#        description = "File containing DB password";
#      };
    };

#    gpg = {
#      fingerprint = mkOption {
#        type = types.str;
#        description = "GPG server key fingerprint";
#      };
    #    };

    securitySaltFile = mkOption {
      type = types.path;
      default = config.sops.secrets."passbolt-security-salt".path;
      description = "File containing CakePHP security salt";
    };
    
    gpg = {
      fingerprintFile = mkOption {
        type = types.path;
        default = "/var/lib/passbolt/gpg-fingerprint";
        description = "Path to file containing GPG server key fingerprint";
      };
      publicKeyFile = mkOption {
        type = types.path;
        default = "/var/lib/passbolt/serverkey.asc";
        description = "Path to file containing public GPG server key";
      };
      privateKeyFile = mkOption {
        type = types.path;
        default = "/var/lib/passbolt/serverkey_private.asc";
        description = "Path to file containing private GPG server key";
      };
    };
    adminFirstName = mkOption {
      type = types.str;
      default = "Marcus";
    };
    adminLastName = mkOption {
      type = types.str;
      default = "Lövgren";
    };
    adminEmail = mkOption {
      type = types.str;
      default = "marcus.lovgrn@proton.me";
    };
  };

  config = mkIf cfg.enable {
    users.users.passbolt = {
      isSystemUser = true;
      group = "passbolt";
#      home = "/var/lib/passbolt";
#      createHome = true;
    };

    users.groups.passbolt = {};

    services = {
      ddclient.domains = [
        "${cfg.hostName}"
      ];

      mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ cfg.database.name ];
        ensureUsers = [{
          name = cfg.database.user;
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };
        }];
      };

      phpfpm.pools.passbolt = {
        user = "nginx";
        group = "nginx";
        
        phpPackage = phpPackage;

        phpEnv = {
          HOME = "/var/lib/passbolt";
          TMP="/var/lib/passbolt/tmp";
          GNUPGHOME = "/var/lib/passbolt/.gnupg";
          PHP="${phpPackage}/bin/php";
          APP_FULL_BASE_URL = "https://${cfg.hostName}";
          SECURITY_SALT="${cfg.securitySaltFile}";
          DATASOURCES_DEFAULT_HOST = "${cfg.database.host}";
          DATASOURCES_DEFAULT_USERNAME = "${cfg.database.user}";
          DATASOURCES_DEFAULT_DATABASE = "${cfg.database.name}";
          PASSBOLT_GPG_SERVER_KEY_PUBLIC = "${cfg.gpg.publicKeyFile}";
          PASSBOLT_GPG_SERVER_KEY_PRIVATE = "${cfg.gpg.privateKeyFile}";
          CACHE_DEFAULT_URL="file:///var/lib/passbolt/cache";
          CACHE_CACKECORE_URL="file:///var/lib/passbolt/cache/persistent";
          PASSBOLT_JWT_PRIVATE_KEY="/var/lib/passbolt/jwt/private.key";
          PASSBOLT_JWT_PUBLIC_KEY="/var/lib/passbolt/jwt/public.key";
          LOG_DEBUG_URL="file:///var/lib/passbolt/logs";
          LOG_ERROR_URL="file:///var/lib/passbolt/logs";
          LOG_QUERIES_URL="file:///var/lib/passbolt/logs";
          PASSBOLT_ADMIN_EMAIL="marcus.lovgren@proton.me";
          PASSBOLT_ADMIN_FIRST_NAME="Marcus";
          PASSBOLT_ADMIN_LAST_NAME="Lovgren";
          PASSBOLT_SSL_FORCE="true";
          EMAIL_DEFAULT_FROM_NAME="Passbolt";
          EMAIL_DEFAULT_FROM="marcus.lovgren@proton.me";
          EMAIL_TRANSPORT_DEFAULT_HOST="smtp.gmail.com";
          EMAIL_TRANSPORT_DEFAULT_PORT="465";
          EMAIL_TRANSPORT_DEFAULT_USERNAME="marcuslvgrn@gmail.com";
          EMAIL_TRANSPORT_DEFAULT_TLS="true";
          APP_DEFAULT_TIMEZONE="Europe/Stockholm";
        };
        
        settings = {
          "listen.owner" = "nginx";
          "listen.group" = "nginx";
          "pm" = "dynamic";
          "pm.max_children" = "32";
          "pm.min_spare_servers" = "1";
          "pm.max_spare_servers" = "3";
          "pm.start_servers" = "2";
#          "clear-env" = "no";
        };
      };

      nginx.enable = true;

      nginx.virtualHosts.${cfg.hostName} = {
        enableACME = true;
        forceSSL = true;
                
        root = "${passboltPackage}/share/php/passbolt/webroot";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Port 443;
        '';
        
        locations."/" = {
          index = "index.php";
          tryFiles = "$uri $uri/ /index.php?$args";
        };
        locations."~ \\.php\$" = {
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.passbolt.socket};
            try_files                $uri =404;
            include ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_index            index.php;
            fastcgi_intercept_errors on;
            fastcgi_split_path_info  ^(.+\.php)(.+)$;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param            SERVER_NAME $http_host;
            fastcgi_param PHP_VALUE  "upload_max_filesize=5M \n post_max_size=5M";
          '';
        };
      };
    };
    
    systemd.tmpfiles.rules = [
      "d /var/lib/passbolt 0750 nginx nginx -"
      "d /var/lib/passbolt/cache 0750 nginx nginx -"
      "d /var/lib/passbolt/logs 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp 0750 nginx nginx -"
      "d /var/lib/passbolt/.gnupg 0700 nginx nginx -"
      "d /var/lib/passbolt/jwt 0500 nginx nginx -"
      "f /var/lib/passbolt/jwt/jwt.key 0600 nginx nginx -"
      "f /var/lib/passbolt/jwt/jwt.pem 0600 nginx nginx -"
      "d /var/lib/passbolt/gpg 0700 nginx nginx -"
      "d /var/lib/passbolt/tmp 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/avatars 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/avatars/empty 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/cache 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/cache/database 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/cache/database/empty 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/selenium 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/selenium/empty 0750 nginx nginx -"
      "d /var/lib/passbolt/tmp/empty 0750 nginx nginx -"
    ];

    systemd.services.passbolt-gpg-init = {
      description = "Initialize Passbolt GPG key";
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-passbolt.service" ];
      after = [ "local-fs.target" "systemd-tmpfiles-setup.service" ];
      wants = [ "systemd-tmpfiles-setup.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        User = "nginx";
        Group = "nginx";
        Environment = [
          "HOME=/var/lib/passbolt"
          "GNUPGHOME=/var/lib/passbolt/.gnupg"
          "PATH=/run/current-system/sw/bin"
        ];
        ExecStart = pkgs.writeShellScript "passbolt-gpg-init" ''
          set -euo pipefail
    
          ${pkgs.coreutils}/bin/mkdir -p "$GNUPGHOME"
          chmod 700 "$GNUPGHOME"
    
          # If keys already exist, do nothing
          if [ -f ${cfg.gpg.privateKeyFile} ] && [ -f ${cfg.gpg.publicKeyFile} ]; then
            echo "Passbolt GPG keys already exist"
            exit 0
          fi

          echo "Generating Passbolt GPG key..."

        ${pkgs.gnupg}/bin/gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Passbolt Server
Name-Email: passbolt@${cfg.hostName}
Expire-Date: 0
%no-protection
%commit
EOF

        fingerprint="$(${pkgs.gnupg}/bin/gpg --list-secret-keys --with-colons \
          | awk -F: '/^fpr:/ { print $10; exit }')"
  
        if [ -z "$fingerprint" ]; then
          echo "ERROR: Failed to obtain GPG fingerprint"
          exit 1
        fi

        echo "PASSBOLT_GPG_SERVER_KEY_FINGERPRINT=$fingerprint" > ${cfg.gpg.fingerprintFile}
        chmod 600 ${cfg.gpg.fingerprintFile}
  
        # Export keys
        ${pkgs.gnupg}/bin/gpg --armor --export "$fingerprint" \
          > ${cfg.gpg.publicKeyFile}
  
        ${pkgs.gnupg}/bin/gpg --armor --export-secret-keys "$fingerprint" \
          > ${cfg.gpg.privateKeyFile}

        chmod 644 ${cfg.gpg.publicKeyFile}
        chmod 600 ${cfg.gpg.privateKeyFile}
        echo "Passbolt GPG initialized"
        echo "Fingerprint: $fingerprint"
      '';
      };
    };
    
    systemd.services.passbolt-bootstrap = {
      description = "Passbolt install, migrate and create-admin";
      wantedBy = [ "multi-user.target" ];
      after = [ "mysql.service" "systemd-tmpfiles-setup.service" "phpfpm-passbolt.service" ];
      requires = [ "mysql.service" "systemd-tmpfiles-setup.service" "phpfpm-passbolt.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "nginx";
        Group = "nginx";
        WorkingDirectory = passboltPackage;
        EnvironmentFile = cfg.gpg.fingerprintFile;
        Environment = [
          "HOME=/var/lib/passbolt"
          "TMP=/var/lib/passbolt/tmp"
          "GNUPGHOME=/var/lib/passbolt/.gnupg"
          "PHP=${phpPackage}/bin/php"
          "APP_FULL_BASE_URL=https://${cfg.hostName}"
          "SECURITY_SALT=${cfg.securitySaltFile}"
          "DATASOURCES_DEFAULT_HOST=${cfg.database.host}"
          "DATASOURCES_DEFAULT_USERNAME=${cfg.database.user}"
#          "DATASOURCES_DEFAULT_PASSWORD="
          "DATASOURCES_DEFAULT_DATABASE=${cfg.database.name}"
          "PASSBOLT_GPG_SERVER_KEY_PUBLIC=${cfg.gpg.publicKeyFile}"
          "PASSBOLT_GPG_SERVER_KEY_PRIVATE=${cfg.gpg.privateKeyFile}"
          "CACHE_DEFAULT_URL=file:///var/lib/passbolt/cache"
          "CACHE_CACKECORE_URL=file:///var/lib/passbolt/cache/persistent"
          "PASSBOLT_JWT_PRIVATE_KEY=/var/lib/passbolt/jwt/private.key"
          "PASSBOLT_JWT_PUBLIC_KEY=/var/lib/passbolt/jwt/public.key"
          "LOG_DEBUG_URL=file:///var/lib/passbolt/logs"
          "LOG_ERROR_URL=file:///var/lib/passbolt/logs"
          "LOG_QUERIES_URL=file:///var/lib/passbolt/logs"
          "PASSBOLT_ADMIN_EMAIL=marcus.lovgren@proton.me"
          "PASSBOLT_ADMIN_FIRST_NAME=Marcus"
          "PASSBOLT_ADMIN_LAST_NAME=Lovgren"
          "PASSBOLT_SSL_FORCE=true"
          "EMAIL_DEFAULT_FROM_NAME=Passbolt"
          "EMAIL_DEFAULT_FROM=marcus.lovgren@proton.me"
          "EMAIL_TRANSPORT_DEFAULT_HOST=smtp.gmail.com"
          "EMAIL_TRANSPORT_DEFAULT_PORT=465"
          "EMAIL_TRANSPORT_DEFAULT_USERNAME=marcuslvgrn@gmail.com"
          "EMAIL_TRANSPORT_DEFAULT_TLS=true"
          "APP_DEFAULT_TIMEZONE=Europe/Stockholm"
        ];
      };

      script = ''
        set -euo pipefail
    
        CAKE="${phpPackage}/bin/php ${passboltPackage}/share/php/passbolt/bin/cake.php"

        echo "==> Available cake commands:"    
        $CAKE passbolt --help
        echo "==> Checking installation state"
    
        # 1️⃣ Install if autoload.php does not exist
#        if [ ! -f "${passboltPackage}/share/php/passbolt/vendor/autoload.php" ]; then
          echo "==> Installing Passbolt (no admin)"
#          $CAKE passbolt install --no-admin
          printf "%s\n%s\n%s\n" \
          "marcus.lovgren@proton.me" \
          "Admin" \
          "User" \
          | $CAKE passbolt install --force
#        else
#          echo "==> Passbolt already installed"
#        fi

        # 2️⃣ Create JWT keys if missing or empty
        if [ ! -s "/var/lib/passbolt/jwt/private.key" ]; then
          echo "==> Creating JWT keys"
          $CAKE passbolt create_jwt_keys --force
        else
          echo "==> JWT keys already exist"
        fi

        echo "==> Running database migrations"
        $CAKE passbolt migrate
    
        echo "==> Running healthcheck"
        $CAKE passbolt healthcheck
    
        echo "==> Checking for existing admin user"
        if ! $CAKE passbolt users_index | grep -q "$PASSBOLT_ADMIN_EMAIL"; then
          echo "==> Creating admin user"
          $CAKE passbolt register_user \
            --role admin \
            --username "$PASSBOLT_ADMIN_EMAIL" \
            --first-name "$PASSBOLT_ADMIN_FIRST_NAME" \
            --last-name "$PASSBOLT_ADMIN_LAST_NAME"
        else
          echo "==> Admin user already exists"
        fi

#        ACTIVE=$($CAKE passbolt users_index | grep 'marcus.lovgren@proton.me' | ${pkgs.gawk}/bin/awk '{print $12}') 
#        if [ "$ACTIVE" = "no" ]; then
#           echo "Admin user inactive"
#           $CAKE passbolt recover_user --username 'marcus.lovgren@proton.me'
#        fi
      '';
##        ExecStart = ''
#          ${phpPackage}/bin/php ${passboltPackage}/share/php/passbolt/bin/cake.php passbolt install --no-admin
#        '';
#        ExecStartPost = ''
#          ${phpPackage}/bin/php ${passboltPackage}/share/php/passbolt/bin/cake.php passbolt healthcheck
#        '';
#      };
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "passbolt-cake" ''
          export HOME=/var/lib/passbolt
          export TMP=/var/lib/passbolt/tmp
          export GNUPGHOME=/var/lib/passbolt/.gnupg
          export PHP=${phpPackage}/bin/php
          export APP_FULL_BASE_URL=https://${cfg.hostName}
          export SECURITY_SALT=${cfg.securitySaltFile}
          export DATASOURCES_DEFAULT_HOST=${cfg.database.host}
          export DATASOURCES_DEFAULT_USERNAME=${cfg.database.user}
          export DATASOURCES_DEFAULT_PASSWORD=
          export DATASOURCES_DEFAULT_DATABASE=${cfg.database.name}
          export PASSBOLT_GPG_SERVER_KEY_PUBLIC=${cfg.gpg.publicKeyFile}
          export PASSBOLT_GPG_SERVER_KEY_PRIVATE=${cfg.gpg.privateKeyFile}
          export CACHE_DEFAULT_URL=file:///var/lib/passbolt/cache
          export CACHE_CACKECORE_URL=file:///var/lib/passbolt/cache/persistent
          export PASSBOLT_JWT_PRIVATE_KEY=/var/lib/passbolt/jwt/private.key
          export PASSBOLT_JWT_PUBLIC_KEY=/var/lib/passbolt/jwt/public.key
          export LOG_DEBUG_URL=file:///var/lib/passbolt/logs
          export LOG_ERROR_URL=file:///var/lib/passbolt/logs
          export LOG_QUERIES_URL=file:///var/lib/passbolt/logs
          export PASSBOLT_ADMIN_EMAIL=marcus.lovgren@proton.me
          export PASSBOLT_ADMIN_FIRST_NAME=Marcus
          export PASSBOLT_ADMIN_LAST_NAME=Lovgren
          export PASSBOLT_SSL_FORCE=true
        exec ${phpPackage}/bin/php \
          ${passboltPackage}/share/php/passbolt/bin/cake.php passbolt "$@"
      '')
    ];
  };
}
