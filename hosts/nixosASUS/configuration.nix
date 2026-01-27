{ config, lib, hostCfg, ... }:

{
  imports = [
    ../../common/configuration.nix
    ./disk-config.nix
  ];

  config = {
    services.xserver.desktopManager.xfce.enable = true;
 
    # Autologin a user
    services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
    };
  };
}

