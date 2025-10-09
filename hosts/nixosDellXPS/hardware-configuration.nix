{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/dcabbd78-7298-431a-8877-cabf3a77a6e2";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/dcabbd78-7298-431a-8877-cabf3a77a6e2";
      fsType = "btrfs";
      options = [ "subvol=@var_log" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/dcabbd78-7298-431a-8877-cabf3a77a6e2";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-uuid/8838-148D";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.vboxnet0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp114s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
