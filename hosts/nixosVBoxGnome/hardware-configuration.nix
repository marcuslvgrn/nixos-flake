{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@swap" ];
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens33.useDHCP = lib.mkDefault true;

}
