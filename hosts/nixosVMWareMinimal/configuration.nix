# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../common/configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  virtualisation.vmware.guest.enable = true;
}

