{
#  pkgs,
#  lib,
  inputs,
  ...
}:
{
  #load the module
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    #for multi disk btrfs, declare secondary drives first
    disk.disk1 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_S3YJNX0K804219W";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            size = "100%";
            label = "ROOT2";
          };
        };
      };
    };
    disk.disk3 = {
      device = "/dev/disk/by-id/ata-Crucial_CT525MX300SSD1_17291800BCF6";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            size = "100%";
            label = "ROOT3";
          };
        };
      };
    };
    #this is the primary drive, reference other drives as extraArgs
    disk.disk2 = {
      device = "/dev/disk/by-id/ata-KINGSTON_SV300S37A240G_50026B724B08A4E8";
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
            label = "ROOT";
            content = {
              type = "btrfs";
              extraArgs = [
                "--force"
                "--data single"
                "--metadata raid1"
                "/dev/disk/by-partlabel/ROOT2"
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
                "/@data" = {
                  mountOptions = [ "compress=zstd:1" ];
                  mountpoint = "/mnt/data";
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
