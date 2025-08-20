# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

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

