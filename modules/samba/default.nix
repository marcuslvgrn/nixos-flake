{
  config,
  lib,
  ...
}:
let
  cfg = config.samba;
  mountPointType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Samba share name.";
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "Filesystem path exported by this share.";
      };
    };
  };
in
{
  options.samba = {
    workgroup = lib.mkOption {
      type = lib.types.str;
      default = "WORKGROUP";
      description = "Samba workgroup name.";
    };
    serverString = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Description advertised for this Samba server.";
    };
    netbiosName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "NetBIOS name advertised by Samba.";
    };
    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "192.168.0."
        "127.0.0.1"
        "localhost"
      ];
      description = "Host patterns allowed to connect to Samba.";
    };
    guestAccount = lib.mkOption {
      type = lib.types.str;
      default = "lovgren";
      description = "Local account used for guest Samba access.";
    };
    mountPoints = lib.mkOption {
      type = lib.types.listOf mountPointType;
      default = [
        {
          name = "data";
          path = "/mnt/data";
        }
      ];
      example = [
        {
          name = "media";
          path = "/srv/media";
        }
        {
          name = "backups";
          path = "/srv/backups";
        }
      ];
      description = "Samba shares to export, each with a share name and filesystem path.";
    };
  };

  config = lib.mkIf config.services.samba.enable {
    assertions =
      let
        shareNames = map (mountPoint: mountPoint.name) cfg.mountPoints;
      in
      [
        {
          assertion = builtins.length shareNames == builtins.length (lib.unique shareNames);
          message = "samba.mountPoints must use a unique name for each share.";
        }
        {
          assertion = !(builtins.elem "global" shareNames);
          message = "samba.mountPoints cannot use the reserved share name \"global\".";
        }
        {
          assertion = config.users.users ? ${cfg.guestAccount};
          message = "samba.guestAccount must name a local user configured on this host.";
        }
      ];

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
            "workgroup" = cfg.workgroup;
            "server string" = cfg.serverString;
            "netbios name" = cfg.netbiosName;
            "security" = "user";
            "hosts allow" = lib.concatStringsSep " " cfg.allowedHosts;
            "hosts deny" = "0.0.0.0/0";
            "guest account" = cfg.guestAccount;
            "map to guest" = "bad user";
            "create mask" = "0664";
            "directory mask" = "0775";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "public" = "yes";
            "force group" = "users";
          };
        }
        // lib.listToAttrs (
          map (mountPoint: {
            name = mountPoint.name;
            value.path = mountPoint.path;
          }) cfg.mountPoints
        );
      };
    };
  };
}
