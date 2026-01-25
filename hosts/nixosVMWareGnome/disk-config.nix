{ pkgs, lib, inputs, ... }:
{
  #load the module
  imports = [
    inputs.disko.nixosModules.disko
  ];
  
  disko.devices = {
    disk.disk1 = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "ESP";
            label = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/efi";
            };
          };
          root = {
            size = "100%";
            label = "ROOT";
            content = {
              type = "btrfs";
              extraArgs = [
                "--force" # Override existing partition
#                "--data single"
#                "--metadata raid1"
#                "/dev/disk/by-partlabel/ROOT2"
              ]; 
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
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
                    swapfile.size = "4G";
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
