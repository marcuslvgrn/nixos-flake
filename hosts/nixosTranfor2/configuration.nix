{ inputs, config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:

let
  # Overlay to force GTK2 for Emacs
  overlay = self: super: {
    emacs = super.emacs.override {
      withGTK2 = true;
      withGTK3 = false;
    };
  };

  pkgsHost = import <nixpkgs> {
    system = builtins.currentSystem;
    overlays = [ overlay ];
  };
in {
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/virtualbox-guest.nix
    ../../common/nextcloud.nix
    ../../common/airsonic.nix
    ../../common/nginx.nix
    ../../common/vaultwarden.nix
    ./disk-config.nix
  ];
  
  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      enable = true;
      smbd.enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "Tranfor2";
          "netbios name" = "Tranfor2";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.0. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
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
    (with cfgPkgs; [
      technitium-dns-server
      compose2nix
      docker-compose
      #to solve ssh -X errors from gnome
      glib.dev
      gsettings-desktop-schemas
      php82
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
#  environment.etc."glib-2.0/schemas".source = "${cfgPkgs.gsettings-desktop-schemas}/share/glib-2.0/schemas";
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
#        ${cfgPkgs.glib.dev}/bin/glib-compile-schemas /run/current-system/sw/share/glib-2.0/schemas
#      fi
#    '';
#  };
}
