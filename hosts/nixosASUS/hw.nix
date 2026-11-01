{
  ...
}:

{
  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
    fsType = "btrfs";
    options = [ "subvol=rootfs" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };
  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/ae0525ee-f0d4-42a9-b6c6-691de903b601";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };
  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/FEE6-261B";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

}
