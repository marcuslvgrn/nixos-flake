{ lib, inputs, ... }:
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
              extraArgs = [ "-f" ]; # Override existing partition
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "/@" = {
                  mountpoint = "/";
                };
                # Subvolume name is the same as the mountpoint
                "/@home" = {
#                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };
                # Subvolume for the swapfile
                "/@swap" = {
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
