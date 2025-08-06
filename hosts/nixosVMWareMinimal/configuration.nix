# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, home-manager, hostname, ... }:

{
  imports = [
    # Include the results of the hardware scan.
#    ./hardware-configuration.nix
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/networkmanager.nix
    ../../common/vmware-guest.nix
    ./disk-config.nix
  ];

  networking.hostName = hostname;

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4 * 1024;
  }];

}

