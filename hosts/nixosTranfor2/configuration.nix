# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/virtualbox-guest.nix
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
  environment.systemPackages = with cfgPkgs; [
    technitium-dns-server
    compose2nix
  ]; 

}

