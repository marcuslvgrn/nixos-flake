# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/vmware-guest.nix
    ./disk-config.nix
  ];

}

