{ config, lib, hostCfg, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/xfce.nix
    ./disk-config.nix
  ];

  networking.hostName = "nixosASUS";

  nixpkgs.hostPlatform = hostCfg.system;

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
}

