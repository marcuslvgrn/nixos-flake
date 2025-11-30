{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@data" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-partlabel/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

#  swapDevices = [ {
#    device = "/swap/swapfile";
#    size = 8*1024;
#  } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.interfaces.enp3s0f2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;
  networking.useDHCP = lib.mkForce false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking = {
    nameservers = [ "192.168.0.7" ];
    interfaces.eno1 = {
      ipv4.addresses = [{
        address = "192.168.0.7";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eno1";
    };
    search = [
      "local"
    ];
  };
}
