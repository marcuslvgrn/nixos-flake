{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let flakecfg = config.flakecfg;
in with lib; {

  nixpkgs.overlays = [
#    # Emacs GTK2 override
#    (final: prev: {
#      emacs = prev.emacs.override {
#        withGTK2 = true;
#        withGTK3 = false;
#      };
#    })
  ];

#let
#  # Overlay to force GTK2 for Emacs
#  overlay = self: super: {
#    emacs = super.emacs.override {
#      withGTK2 = true;
#      withGTK3 = false;
#    };
#  };
#
#  pkgsHost = import <nixpkgs> {
#    system = builtins.currentSystem;
#    overlays = [ overlay ];
#  };
#in {
  imports = [
    ../../common/airsonic.nix
    ../../common/nginx.nix
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/nextcloud.nix
    ../../common/vaultwarden.nix
    ../../common/technitium.nix
    ../../common/ddclient.nix
    ../../common/passbolt.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  flakecfg = {
    airsonic = {
      enable = true;
      hostName = "mlairsonic.dynv6.net";
    };
    ddclient.enable = true;
    nextcloud = {
      enable = true;
      nextcloudHostName = "mlnextcloud.dynv6.net";
      collaboraHostName = "mlcollabora.dynv6.net";
    };
    nginx.enable = true;
    samba.enable = true;
    technitium = {
      enable = true;
      hostName = "mltechnitium.dynv6.net";
    };
    vaultwarden = {
      enable = true;
      hostName = "mlvaultwarden.dynv6.net";
    };
    #userNames = mkAfter [ "gerd" ];
  };
  
  services = {
    passbolt = {
      enable = false;
      hostName = "mlpassbolt.dynv6.net";
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    iperf3.enable = true;
    cron = {
      enable = true;
      systemCronJobs = [
        "0 1 * * *   root      /run/current-system/sw/bin/rtcwake -m off -s 21600 >> /root/cron.log 2>&1"
      ];
    };
    logrotate.enable = true;
    printing = {
      enable = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
    samba = {
      enable = true;
      smbd.enable = true;
      nmbd.enable = true;
      winbindd.enable = true;
      nsswins = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "nixosTranfor";
          "netbios name" = "nixosTranfor";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.0. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "lovgren";
          "map to guest" = "bad user";
          "create mask" = "0664";
          "directory mask" = "0775";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "public" = "yes";
          #        "force user" = "username";
          "force group" = "users";
        };
        "data" = {
          "path" = "/mnt/data";
        };
      };
    };
  };
  
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  #Packages only installed on this host
  environment.systemPackages =
    (with pkgs; [
      compose2nix
      docker-compose
      #to solve ssh -X errors from gnome
      glib.dev
      gsettings-desktop-schemas
      php82
      mariadb
      util-linux
      ethtool
      net-tools
      cups
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [

    ]);
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
