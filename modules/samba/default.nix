{
  config,
  lib,
  ...
}:
with lib;
{

  config = mkIf config.services.samba.enable {
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
