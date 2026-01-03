{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:

{

  nixpkgs.overlays = [
    # Technitium version override
    (import ../../overlays/technitium-overlay.nix)

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
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/nextcloud.nix
    ../../common/airsonic.nix
    ../../common/nginx.nix
    ../../common/vaultwarden.nix
    ../../common/technitium.nix
    ../../common/ddclient.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  services = {
    logrotate.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    printing = {
      enable = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
    iperf3.enable = true;
    cron = {
      enable = true;
      systemCronJobs = [
        "0 1 * * *   root      /run/current-system/sw/bin/rtcwake -m off -s 21600 >> /root/cron.log 2>&1"
      ];
    };
#    smb-wsdd.enable = true;
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
#      technitium-dns-server
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
