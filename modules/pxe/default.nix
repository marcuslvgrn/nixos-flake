{
  config,
#  pkgs,
  lib,
#  hostCfg,
  inputLib,
  ...
}:
with lib;
let
  sys = inputLib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      (
        {
#          config,
#          pkgs,
#          lib,
          modulesPath,
          ...
        }:
        {
          imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];
          config = {
            console.keyMap = "sv-latin1";
            system.stateVersion = "25.05";
            services.openssh = {
              enable = true;
              openFirewall = true;

              settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
              };
            };

            #          users.users.root.openssh.authorizedKeys.keys = [
            #            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
            #          ];
          };
        }
      )
    ];
  };

  build = sys.config.system.build;

in
{
  services = mkIf config.services.pixiecore.enable {
    pixiecore = {
      openFirewall = true;
      dhcpNoBind = true;

      mode = "boot";
      kernel = "${build.kernel}/bzImage";
      initrd = "${build.netbootRamdisk}/initrd";
      cmdLine = "init=${build.toplevel}/init loglevel=4";
      #      debug = true;

      #      kernel = "https://boot.netboot.xyz";

      statusPort = 81;
      port = 81;
    };
  };
}
