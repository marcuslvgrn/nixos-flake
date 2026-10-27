{
  #  config,
  lib,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:
with lib;
let

in
{

  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  config = {
    services.printing.enable = true;

    airsonic = {
      hostName = "mlairsonic.dynv6.net";
    };
    nextcloud = {
      nextcloudHostName = "mlnextcloud.dynv6.net";
      collaboraHostName = "mlcollabora.dynv6.net";
    };
    #enables proxy to external hosts
    nginxExternal = {
      enable = true;
      # Reverse proxy entries for LAN devices exposed via dynv6.
      # Keys are public hostnames, values are the internal backend targets.
      proxyHosts = {
        "mlmodem.dynv6.net" = {
          target = "http://192.168.0.1";
          recommendedProxySettings = false;
          recommendedTlsSettings = true;
        };
        "mlrouter.dynv6.net" = {
          target = "http://192.168.0.2:80";
          recommendedProxySettings = true;
          recommendedTlsSettings = false;
        };
        "mllinksys.dynv6.net" = {
          target = "http://192.168.0.3:80";
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
        };
        "mlproxmox.dynv6.net" = {
          target = "https://192.168.0.10:8006";
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 0;
            proxy_connect_timeout 3600s;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            send_timeout 3600s;
          '';
        };
        #"mlpassbolt.dynv6.net" = {
        #  target = "https://192.168.0.7:444";
        #  recommendedProxySettings = true;
        #  recommendedTlsSettings = true;
        #};
      };
      # Additional domains to keep updated in ddclient but not proxied here
      # (they are handled by their own services on this host).
      extraDdclientDomains = [
        "mldrupal.dynv6.net"
        "mlgeegnomer.dynv6.net"
        "mlplex.dynv6.net"
        "mlportainer.dynv6.net"
        "mlrustdesk.dynv6.net"
        "mlsynology.dynv6.net"
        "mlwebmin.dynv6.net"
      ];
    };
    passbolt = {
      #      enable = true;
      hostName = "mlpassbolt.dynv6.net";
      adminFirstName = "Marcus";
      adminLastName = "Lövgren";
      adminEmail = "marcus.lovgren@proton.me";
      gmailUserName = "marcuslvgrn@gmail.com";
    };
    technitium = {
      hostName = "mltechnitium.dynv6.net";
    };
    vaultwarden = {
      hostName = "mlvaultwarden.dynv6.net";
    };

    nixpkgs.overlays = [
    ];

    services = {
      airsonic.enable = true;
      cron = {
        enable = true;
        systemCronJobs = [
          "0 1 * * *   root      /run/current-system/sw/bin/rtcwake -m off -s 21600 >> /root/cron.log 2>&1"
        ];
      };
      ddclient.enable = true;
      iperf3.enable = true;
      logrotate.enable = true;
      nextcloud.enable = true;
      pixiecore.enable = true;
      samba.enable = true;
      technitium-dns-server.enable = true;
      vaultwarden.enable = true;
    };

    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };

    #Packages only installed on this host
    environment.systemPackages = (
      with pkgs;
      [
        compose2nix # Generate a NixOS config from a Docker Compose project
        docker-compose
        mariadb
        util-linux # Set of system utilities for Linux
        ethtool # Utility for controlling network drivers and hardware
        net-tools # Set of tools for controlling the network subsystem in Linux
        cups
      ]
    )
    #      ++ (with pkgs-stable; [])
    #      ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
    ;
  };
  #  # Ensure schema directories are visible system-wide
  #  environment.pathsToLink = [
  #    "/share/glib-2.0/schemas"
  #  ];
  #  environment.etc."glib-2.0/schemas".source = "${pkgs.gsettings-desktop-schemas}/share/glib-2.0/schemas";
  #
  #  environment.sessionVariables = {
  #    XDG_DATA_DIRS = "/run/current-system/sw/share";
  #    GSETTINGS_SCHEMA_DIR = "/run/current-system/sw/share/glib-2.0/schemas";
  #  };
  #
  #  # Automatically compile schemas at build time
  #  system.activationScripts.glibCompileSchemas = {
  #    text = ''
  #      if [ -d "/run/current-system/sw/share/glib-2.0/schemas" ]; then
  #        echo "Compiling GLib schemas..."
  #        ${pkgs.glib.dev}/bin/glib-compile-schemas /run/current-system/sw/share/glib-2.0/schemas
  #      fi
  #    '';
  #  };
}
