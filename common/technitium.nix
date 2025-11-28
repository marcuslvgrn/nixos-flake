{ inputs, config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:
{
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
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };
  };
}
