{
  config,
  #  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
{
  #load the module
  imports = [
    inputs.disko.nixosModules.disko
  ];

  #set some options
  options = {
    diskoConfig = {
      enable = mkEnableOption "Enable the common disko module";
      espSize = mkOption {
        type = lib.types.str;
        description = "Set the size of the esp partition";
        default = "500M";
      };
      rootSize = mkOption {
        type = lib.types.str;
        description = "Set the size of the root partition";
        default = "100%";
      };
      swapSize = mkOption {
        type = lib.types.str;
        description = "Set the size of the swap file";
        default = "4G";
      };
      device = mkOption {
        type = lib.types.str;
        description = "Root device name";
        default = "/dev/sda";
      };
      mountOptions = mkOption {
        type = types.listOf types.str;
        description = "mount options like compression";
        default = [ "compress=zstd:1" ];
      };
    };
  };

  config = {
    disko.devices = mkIf config.diskoConfig.enable {
      disk.disk1 = {
        device = config.diskoConfig.device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              label = "ESP";
              size = config.diskoConfig.espSize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
              };
            };
            root = {
              size = config.diskoConfig.rootSize;
              label = "ROOT";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/@" = {
                    mountOptions = config.diskoConfig.mountOptions;
                    mountpoint = "/";
                  };
                  # Subvolume name is the same as the mountpoint
                  "/@home" = {
                    mountOptions = config.diskoConfig.mountOptions;
                    mountpoint = "/home";
                  };
                  # Subvolume for the swapfile
                  "/@swap" = {
                    mountOptions = config.diskoConfig.mountOptions;
                    mountpoint = "/swap";
                    swap = {
                      swapfile.size = config.diskoConfig.swapSize;
                    };
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
