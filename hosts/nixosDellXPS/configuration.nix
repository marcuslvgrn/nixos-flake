# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/gnome.nix
    ../../common/grub.nix
    ../../common/networkmanager.nix
    ../../common/openssh.nix
    ../../common/users.nix
    ../../common/sops.nix
  ];

  networking.hostName = "nixosDellXPS";

  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/grub/grubx64.efi
    }
  '';

#  swapDevices = [{
#    device = "/swap/swapfile";
#    size = 8 * 1024;
#  }];

}

