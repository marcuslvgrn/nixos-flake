{
  ...
}:

{
  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  # There is an SSD
  ssd.enable = true;

  # Boot
  # Specify hibernation options
  boot.kernelParams = [
    "resume_offset=8628224"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";

  # Filesystems
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024;
    }
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:1"
    ];
  };
  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "compress=none"
    ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:1"
    ];
  };
  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";
    fsType = "btrfs";
    options = [
      "subvol=@var_log"
      "compress=zstd:1"
    ];
  };
  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/EB52-3F8D";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # Disable wakeup from suspend/hibernate triggered by PCIe root ports.
  # On Dell XPS laptops, PCIe devices (network/USB controllers, etc.) can
  # cause spurious wakeups that drain battery while the lid is closed.
  # This rule sets power/wakeup=disabled on all pcieport devices at boot.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled" 
  '';

  # Enable GPU acceleration for intel
  intel-gpuacc.enable = true;

}
