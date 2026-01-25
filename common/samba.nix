{ config, pkgs, lib, ... }:
let
  cfg = config.samba;
  serviceCfg = config.services.samba;
in with lib; {

  config = mkIf serviceCfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      samba = {
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
  };
}
