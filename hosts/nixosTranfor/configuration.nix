{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let moduleCfg = config.moduleCfg;
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
    ../../common/configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  services = {
    airsonic.enable = true;
    ddclient.enable = true;
    nextcloud.enable = true;
    samba.enable = true;
    technitium-dns-server.enable = true;
    vaultwarden.enable = true;
  };

  config = {
    airsonic = {
      hostName = "mlairsonic.dynv6.net";
    };
    nextcloud = {
      nextcloudHostName = "mlnextcloud.dynv6.net";
      collaboraHostName = "mlcollabora.dynv6.net";
    };
    #enables proxy to external hosts
    nginx.enable = true;
    passbolt = {
      enable = false;
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
    #userNames = mkAfter [ "gerd" ];
  };
  
  services = {
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
