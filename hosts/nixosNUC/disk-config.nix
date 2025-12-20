{ pkgs, lib, inputs, ... }:
{
  #load the module
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.disk1 = {
      device = "/dev/disk/by-id/ata-INTEL_SSDSC2CT120A3_CVMP21540489120BGN";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "ESP";
            label = "ESP";
            size = "100M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/efi";
            };
          };
          root = {
            size = "100%";
            label = "NIXOSROOT";
            content = {
              type = "btrfs";
              extraArgs = [
#                "--force"
#                "--data single"
#                "--metadata raid1"
#                "/dev/disk/by-partlabel/ROOT2"
              ];
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "/@" = {
                  mountOptions = [ "compress=zstd:1" ];
                  mountpoint = "/";
                };
                # Subvolume name is the same as the mountpoint
                "/@home" = {
                  mountOptions = [ "compress=zstd:1" ];
                  mountpoint = "/home";
                };
                # Subvolume for the swapfile
                "/@swap" = {
                  mountOptions = [ "compress=zstd:1" ];
                  mountpoint = "/swap";
                  swap = {
                    swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
