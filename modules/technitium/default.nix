{
  #  inputs,
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.technitium;
  serviceCfg = config.services.technitium-dns-server;
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
in
{

  options.technitium = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Public hostname for nginx";
    };
    contextPath = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Context path for nginx";
    };
    # This defaults to unstable to preserve the module's previous package pin.
    packageChannel = lib.mkOption {
      type = packageChannel.type;
      # Preserve the module's previous behavior, which pinned this package to unstable.
      default = "unstable";
      description = "Nixpkgs channel to use for the Technitium DNS server package.";
    };
  };

  config = lib.mkIf serviceCfg.enable {
    assertions = [
      {
        assertion = cfg.hostName != "";
        message = "Set technitium.hostName when services.technitium-dns-server.enable is true.";
      }
    ];

    networking.firewall.allowedUDPPorts = [
      53
      67
    ];
    #override the technitium service (disable the DynamicUser, it causes issues with write permissions)
    systemd.services.technitium-dns-server = {
      # Technitium reads this when creating its initial configuration.
      environment.DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES = "127.0.0.1";
      serviceConfig = {
        DynamicUser = lib.mkForce false; # disable ephemeral user
        User = "technitium"; # use a stable system user
        Group = "technitium"; # set the group

        StateDirectory = "technitium-dns-server";

        # Optional: allow writes anywhere under WorkingDirectory
        ReadWritePaths = [ "/var/lib/technitium-dns-server" ];
      };
    };

    #create the system user
    users.users.technitium = {
      isSystemUser = true;
      group = "technitium";
      home = "/var/lib/technitium-dns-server";
    };

    #create the group (default options)
    users.groups.technitium = { };

    services = {

      ddclient.domains = [
        "${cfg.hostName}"
      ];

      technitium-dns-server = {
        openFirewall = true;
        firewallTCPPorts = [ 53 ];
        package = (packageChannel.forChannel cfg.packageChannel).technitium-dns-server;
      };
      nginx = {
        enable = true;
        virtualHosts.${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          locations."${cfg.contextPath}" = {
            proxyPass = "http://127.0.0.1:5380";
          };
        };
      };
    };
  };
}
