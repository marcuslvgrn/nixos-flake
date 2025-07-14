{ config, lib, pkgs, ... }:

{

  #VMware
  # If running as guest
  services.xserver.videoDrivers = [ "vmware" ];
  virtualisation.vmware.guest.enable = true;

}
