 { config, lib, pkgs, modulesPath, ... }:

{
# Use the systemd-boot EFI boot loader.
 # boot.loader.systemd-boot.enable = true;
 
 # Use the GRUB boot loader
  boot.loader.grub = {
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
  
  boot.loader.efi.canTouchEfiVariables = true;
}
