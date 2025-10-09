{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/xfce.nix
    ./disk-config.nix
  ];

  networking.hostName = "nixosASUS";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
}

