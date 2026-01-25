{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.moduleCfg.passbolt;

  passboltVars = {
    PATH="/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH";
    HOME="${cfg.passboltHome}";
    TMP="${cfg.passboltHome}/tmp";
    GNUPGHOME="${cfg.passboltHome}/.gnupg";
    PHP="${phpPackage}/bin/php";
    APP_FULL_BASE_URL="https://${cfg.hostName}";
    SECURITY_SALT="${cfg.securitySaltFile}";
    DATASOURCES_DEFAULT_HOST="${cfg.database.host}";
    DATASOURCES_DEFAULT_USERNAME="${cfg.database.user}";
    #    DATASOURCES_DEFAULT_PASSWORD=
    DATASOURCES_DEFAULT_DATABASE="${cfg.database.name}";
    PASSBOLT_GPG_SERVER_KEY_PUBLIC="${cfg.gpg.publicKeyFile}";
    PASSBOLT_GPG_SERVER_KEY_PRIVATE="${cfg.gpg.privateKeyFile}";
    CACHE_DEFAULT_URL="file://${cfg.passboltHome}/cache";
    #    CACHE_CAKECORE_URL="file://${cfg.passboltHome}/cache/persistent";
    PASSBOLT_JWT_PRIVATE_KEY="${cfg.passboltHome}/jwt/jwt.key";
    PASSBOLT_JWT_PUBLIC_KEY="${cfg.passboltHome}/jwt/jwt.pem";
    LOG_DEBUG_URL="file://${cfg.passboltHome}/logs";
    LOG_ERROR_URL="file://${cfg.passboltHome}/logs";
    LOG_QUERIES_URL="file://${cfg.passboltHome}/logs";
    PASSBOLT_ADMIN_EMAIL="${cfg.adminEmail}";
    PASSBOLT_ADMIN_FIRST_NAME="${cfg.adminFirstName}";
    PASSBOLT_ADMIN_LAST_NAME="${cfg.adminLastName}";
    PASSBOLT_SSL_FORCE="true";
    EMAIL_DEFAULT_FROM_NAME="Passbolt";
    EMAIL_DEFAULT_FROM="${cfg.adminEmail}";
    EMAIL_TRANSPORT_DEFAULT_HOST="smtp.gmail.com";
    EMAIL_TRANSPORT_DEFAULT_PORT="465";
    EMAIL_TRANSPORT_DEFAULT_USERNAME="${cfg.gmailUserName}";
    EMAIL_TRANSPORT_DEFAULT_TLS="true";
    APP_DEFAULT_TIMEZONE="Europe/Stockholm";
  };

  # convert attrset → "export FOO=bar" lines
  passboltEnvExports =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${v}") passboltVars);
  
  # convert attrset → env-file format
  passboltEnvList =
    lib.mapAttrsToList (k: v: "${k}=${v}") passboltVars;
      
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

  environment.systemPackages = with pkgs; [
    gnupg
  ];
  
  #copied from installation default files
  #eventually, use the defaults from installation instead (if no mods are needed)
  #so far everything can be controlled using environment variables
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

    #Move files that should be writable to ${cfg.passboltHome}
    postInstall = ''
      cfgDir=$out/share/php/passbolt/config
      install -m644 ${appPhp} "$cfgDir/app.php"
      install -m644 ${passboltPhp} "$cfgDir/passbolt.php"
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/tmp
      ${pkgs.coreutils}/bin/ln -s ${cfg.passboltHome}/tmp $out/share/php/passbolt/tmp
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/config/jwt
      ${pkgs.coreutils}/bin/ln -s ${cfg.passboltHome}/jwt $out/share/php/passbolt/config/jwt
      ${pkgs.coreutils}/bin/rm -r $out/share/php/passbolt/config/gpg
      ${pkgs.coreutils}/bin/ln -s ${cfg.passboltHome}/gpg $out/share/php/passbolt/config/gpg
      ${pkgs.coreutils}/bin/ln -s ${cfg.passboltHome}/logs $out/share/php/passbolt/logs
      echo "passboltPackage installed"
    '';      
  });

in {
  options.moduleCfg.passbolt = {
    enable = mkEnableOption "Passbolt password manager";

    enableNginxACME = mkEnableOption "Enable ACME for nginx";
    enableNginxSSL = mkEnableOption "Enable SSL for nginx";

    enableDdclient = mkEnableOption "Enable ddclient registration hook";

    passboltHome = mkOption {
      type = types.str;
      default = "/var/lib/passbolt";
      example = "some path to the passbolt home";
    };

    envFile = mkOption {
      type = types.str;
      example = "some path to the file";
    };
    
    hostName = mkOption {
      type = types.str;
      example = "passbolt.example.com";
    };
    
    database = {
      host = mkOption { type = types.str; default = "localhost"; };
      name = mkOption { type = types.str; default = "passbolt"; };
      user = mkOption { type = types.str; default = "nginx"; };
    };
      
    securitySaltFile = mkOption {
      type = types.path;
      default = config.sops.secrets."passbolt-security-salt".path;
      description = "File containing CakePHP security salt";
    };
    
    gpg = {
      fingerprintFile = mkOption {
        type = types.path;
        default = "${cfg.passboltHome}/gpg-fingerprint";
        description = "Path to file containing GPG server key fingerprint";
      };
      publicKeyFile = mkOption {
        type = types.path;
        default = "${cfg.passboltHome}/serverkey.asc";
        description = "Path to file containing public GPG server key";
      };
      privateKeyFile = mkOption {
        type = types.path;
        default = "${cfg.passboltHome}/serverkey_private.asc";
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
      default = "admin@example.com";
    };
    gmailUserName = mkOption {
      type = types.str;
      default = "user@example.com";
    };

    timeZone = mkOption {
      type = types.str;
      default = "Europe/Stockholm";
    };
    
  };
  
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.adminEmail}";
      # Generate ACME certs for all hosts automatically
      certs = {
        "${cfg.hostName}" = {
          webroot = "/var/lib/acme/acme-challenge";
        };
      };
    };
    
    users.users.nginx.extraGroups = [ "acme" ];
    
    services = {
      ddclient = mkIf cfg.enableDdclient {
        domains = [
          "${cfg.hostName}"
        ];
      };

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

#        #do not remove environment variables
#        phpOptions = ''
#          clear_env = no
#        '';
#
        phpEnv = passboltVars;
        
        settings = {
          "listen.owner" = "nginx";
          "listen.group" = "nginx";
          "pm" = "dynamic";
          "pm.max_children" = "32";
          "pm.min_spare_servers" = "1";
          "pm.max_spare_servers" = "3";
          "pm.start_servers" = "2";
        };
      };
      
      nginx.enable = true;

      nginx.virtualHosts.${cfg.hostName} = {
        enableACME = cfg.enableNginxACME;
        forceSSL = cfg.enableNginxSSL;
        #For debugging
#        addSSL = true;
#        sslCertificate = "${cfg.passboltHome}/certs/fullchain.pem";
#        sslCertificateKey = "${cfg.passboltHome}/certs/key.pem";
        #
              
        root = "${passboltPackage}/share/php/passbolt/webroot";
        extraConfig = ''
#          proxy_set_header Host $host;
#          proxy_set_header X-Forwarded-Host $host;
#          proxy_set_header X-Forwarded-Proto https;
#          proxy_set_header X-Forwarded-Port 443;
          index = "index.php";
        '';
        
        locations."/" = {
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
      "d ${cfg.passboltHome} 0750 nginx nginx -"
      "d ${cfg.passboltHome}/cache 0750 nginx nginx -"
      "d ${cfg.passboltHome}/logs 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp 0750 nginx nginx -"
      "d ${cfg.passboltHome}/.gnupg 0700 nginx nginx -"
      "d ${cfg.passboltHome}/jwt 0500 nginx nginx -"
      "f ${cfg.passboltHome}/jwt/jwt.key 0600 nginx nginx -"
      "f ${cfg.passboltHome}/jwt/jwt.pem 0600 nginx nginx -"
      "d ${cfg.passboltHome}/gpg 0700 nginx nginx -"
      "d ${cfg.passboltHome}/tmp 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/avatars 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/avatars/empty 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/cache 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/cache/database 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/cache/database/empty 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/selenium 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/selenium/empty 0750 nginx nginx -"
      "d ${cfg.passboltHome}/tmp/empty 0750 nginx nginx -"
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
        EnvironmentFile = [
          config.sops.secrets."passbolt-env".path
        ];
        Environment = lib.mapAttrsToList (k: v: "${k}=${v}") passboltVars;
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
Name-Email: ${cfg.adminEmail}
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
        EnvironmentFile = [
          cfg.gpg.fingerprintFile
          config.sops.secrets."passbolt-env".path
        ];
        Environment = passboltEnvList;
      };

      script = ''
        set -euo pipefail
    
        CAKE="${phpPackage}/bin/php ${passboltPackage}/share/php/passbolt/bin/cake.php"

        echo "==> Available cake commands:"    
        $CAKE passbolt --help
        echo "==> Checking installation state"
    
        # 2️⃣ Create JWT keys if missing or empty
        $CAKE passbolt create_jwt_keys --force
        if [ ! -s "${cfg.passboltHome}/jwt/jwt.key" ]; then
          echo "==> Creating JWT keys"
          $CAKE passbolt create_jwt_keys --force
        else
          echo "==> JWT keys already exist"
        fi

        # 1️⃣ Install if autoload.php does not exist
#        if [ ! -f "${passboltPackage}/share/php/passbolt/vendor/autoload.php" ]; then
          echo "==> Installing Passbolt (no admin)"
#          $CAKE passbolt install --no-admin
          printf "%s\n%s\n%s\n" \
          "${cfg.adminEmail}" \
          "Admin" \
          "User" \
          | $CAKE passbolt install --force
#        else
#          echo "==> Passbolt already installed"
#        fi

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

        $CAKE passbolt users_index

        #        ACTIVE=$($CAKE passbolt users_index | grep "${cfg.adminEmail}" | ${pkgs.gawk}/bin/awk '{print $12}') 
#        if [ "$ACTIVE" = "no" ]; then
#           echo "Admin user inactive"
#           $CAKE passbolt recover_user --username "${cfg.adminEmail}"
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
          ${passboltEnvExports}
        exec ${phpPackage}/bin/php \
          ${passboltPackage}/share/php/passbolt/bin/cake.php passbolt "$@"
      '')
    ];
  };
}
