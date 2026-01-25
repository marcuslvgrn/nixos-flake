{ config, lib, hostCfg, ... }:

{
  imports = [
    ../../common/configuration.nix
    ./disk-config.nix
  ];

  config = {
    desktop = {
      desktopManagers = {
        xfce = {
          enable = true;
        };
      };
    };
  };

  networking.hostName = "nixosASUS";

  nixpkgs.hostPlatform = hostCfg.system;

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
}

