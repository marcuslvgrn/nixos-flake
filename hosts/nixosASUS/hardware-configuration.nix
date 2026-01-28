{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "sd_mod" "sdhci_acpi" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
      fsType = "btrfs";
      options = [ "subvol=rootfs" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-uuid/FEE6-261B";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

}
