{
  # config,
  lib,
  # pkgs,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/arch/grubx64.efi
    }
  '';

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
    }
  ];

  fileSystems."/mnt/nixosTranfor" = {
    device = "//nixosTranfor/data";
    fsType = "cifs";
    options = [
      "user,users"
      "uid=1000,gid=100"
      "file_mode=0664,dir_mode=0775"
    ];
  };

  #Specify hibernation options
  boot.kernelParams = [
    "resume_offset=2823130"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:1"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "compress=none"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:1"
    ];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/8838-148D";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.vboxnet0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp114s0.useDHCP = lib.mkDefault true;

}
