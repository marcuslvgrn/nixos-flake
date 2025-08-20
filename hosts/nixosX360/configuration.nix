# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/gnome.nix
    ../../common/ssd.nix
  ];

  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/grub/grubx64.efi
    }
  '';

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8 * 1024;
  }];

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
}

