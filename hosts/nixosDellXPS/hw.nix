{
  pkgs,
  ...
}:

{
  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  # Suspend some HW devices during hibernation
  ath11k-suspend.enable = true;
  bluetooth-suspend.enable = true;

  # There is an SSD
  ssd.enable = true;

  # Boot
  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/arch/grubx64.efi
    }
  '';
  #Specify hibernation options
  boot.kernelParams = [
    "resume_offset=2823130"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

  # Filesystems
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

  # Fingerprint sensor
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Disable wakeup from suspend/hibernate triggered by PCIe root ports.
  # On Dell XPS laptops, PCIe devices (network/USB controllers, etc.) can
  # cause spurious wakeups that drain battery while the lid is closed.
  # This rule sets power/wakeup=disabled on all pcieport devices at boot.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  # GPU acceleration for intel
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };
  hardware.graphics = {
    enable = true;
    extraPackages = (
      with pkgs;
      [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        vpl-gpu-rt
      ]
    )
    #        ++ (with pkgs-stable; [])
    #        ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
    ;
  };

}
