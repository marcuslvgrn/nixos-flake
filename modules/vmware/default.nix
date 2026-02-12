{
  config,
  lib,
#  pkgs,
  ...
}:

{
  #VMware
  # If running as guest
  services.xserver = lib.mkIf config.virtualisation.vmware.guest.enable {
    videoDrivers = [ "vmware" ];
  };
}
