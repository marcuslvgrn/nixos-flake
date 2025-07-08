{ config, lib, pkgs, modulesPath, ... }:
{
  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    grub = {
      # Use the GRUB boot loader
      enable = true;
      useOSProber = true;
      efiSupport = true; 
      mirroredBoots = [
        {
          path = "/boot"; 
          efiSysMountPoint = "/efi";
          devices = [ "nodev" ];
        }
      ];
    };
  };
}
