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
  ];

  config = {
    #use the disko module to format the disk
    diskoConfig.enable = true;
    #    airsonic = {
    #      hostName = "mlairsonic.dynv6.net";
    #    };
    #    nextcloud = {
    #      nextcloudHostName = "mlnextcloud.dynv6.net";
    #      collaboraHostName = "mlcollabora.dynv6.net";
    #    };
    #    #enables proxy to external hosts
    #    nginxExternal.enable = true;
    #    passbolt = {
    #      #      enable = true;
    ##      hostName = "mlpassbolt.dynv6.net";
    #      adminFirstName = "Marcus";
    #      adminLastName = "Lövgren";
    #      adminEmail = "marcus.lovgren@proton.me";
    #      gmailUserName = "marcuslvgrn@gmail.com";
    #    };
    #    technitium = {
    #      hostName = "mltechnitium.dynv6.net";
    ##    };
    #    vaultwarden = {
    #      hostName = "mlvaultwarden.dynv6.net";
    #    };

    services = {
      #      airsonic.enable = true;
      #      cron = {
      #        enable = true;
      #        systemCronJobs = [
      #          "0 1 * * *   root      /run/current-system/sw/bin/rtcwake -m off -s 21600 >> /root/cron.log 2>&1"
      #        ];
      #      };
      #      ddclient.enable = true;
      #      iperf3.enable = true;
      #      logrotate.enable = true;
      #      nextcloud.enable = true;
      #      pixiecore.enable = true;
      #      samba.enable = true;
      #      technitium-dns-server.enable = true;
      #      vaultwarden.enable = true;
    };

    #    virtualisation.docker = {
    #      enable = true;
    #      storageDriver = "btrfs";
    #    };

    #Packages only installed on this host
    environment.systemPackages = (
      with pkgs;
      [
        compose2nix
        docker-compose
        php82
        mariadb
        util-linux
        ethtool
        net-tools
        cups
      ]
    )
    #      ++ (with pkgs-stable; [])
    #      ++ (with pkgs-unstable; [])
    ;
  };
}
