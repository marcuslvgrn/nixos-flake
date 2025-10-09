# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ../../services/create-swapfile.nix
    ../../common/grub.nix
    ../../common/openssh.nix
    ../../common/users.nix
    ../../common/sops.nix
    ../../common/configuration.nix
    ../../common/networkmanager.nix
  ];
}

