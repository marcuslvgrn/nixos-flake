{ config, lib, pkgs, ... }:

{
#  imports = [ ];
#
#  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "rtsx_pci_sdmmc" ];
#  boot.initrd.kernelModules = [ ];
#  boot.kernelModules = [ "kvm-intel" ];
#  boot.extraModulePackages = [ ];
#
#  fileSystems."/" =
#    { device = "/dev/disk/by-uuid/ac511088-4db1-4d7f-84a9-30c99e665614";
#      fsType = "btrfs";
#      options = [ "subvol=@" ];
#    };
#
#  fileSystems."/home" =
#    { device = "/dev/disk/by-uuid/ac511088-4db1-4d7f-84a9-30c99e665614";
#      fsType = "btrfs";
#      options = [ "subvol=@home" ];
#    };
#
#  fileSystems."/var/log" =
#    { device = "/dev/disk/by-uuid/ac511088-4db1-4d7f-84a9-30c99e665614";
#      fsType = "btrfs";
#      options = [ "subvol=@var_log" ];
#    };
#
#  fileSystems."/efi" =
#    { device = "/dev/disk/by-uuid/628A-9604";
#      fsType = "vfat";
#      options = [ "fmask=0022" "dmask=0022" ];
#    };
#
#  swapDevices = [ {
#    device = "/swap/swapfile";
#    size = 2*1024;
#  } ];
#
#  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
#  # (the default) this is the recommended approach. When using systemd-networkd it's
#  # still possible to use this option, but it's recommended to use it in conjunction
#  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
#  networking.useDHCP = lib.mkDefault true;
#  # networking.interfaces.enp3s0f2.useDHCP = lib.mkDefault true;
#  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;
#
#  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
#  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking = {
    nameservers = [ "192.168.0.6" ];
    interfaces.enp0s3 = {
      ipv4.addresses = [{
        address = "192.168.0.7";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp0s3";
    };
  };
}
