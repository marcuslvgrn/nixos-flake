{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let
  cfg = config.flakecfg.technitium;
  technitiumCfg = config.services.technitium-dns-server;
in with lib; {

  config = mkIf cfg.enable {

    #override the technitium service (disable the DynamicUser, it causes issues with write permissions)
    systemd.services.technitium-dns-server = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;  # disable ephemeral user
        User = "technitium";              # use a stable system user
        Group = "technitium";             # set the group
        
        StateDirectory = "technitium-dns-server";
        WorkingDirectory = "/var/lib/technitium-dns-server";
        
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
    users.groups.technitium = {};

    services = {

      ddclient.domains = [
        "${cfg.hostName}"
      ];
      
      technitium-dns-server = {
        enable = true;
        openFirewall = true;
        package = pkgs-unstable.technitium-dns-server;
      };
      nginx = {
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
