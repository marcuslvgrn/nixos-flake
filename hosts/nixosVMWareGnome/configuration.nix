{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.moduleCfg;
in with lib;
{
  imports = [
    ../../common/configuration.nix
#    ./hardware-configuration.nix
    ./disk-config.nix
  ];


  config = {
    passbolt = {
      enable = true;
      hostName = "mlpassbolt.dynv6.net";
      adminEmail = "marcus.lovgren@proton.me";
      adminFirstName = "Marcus";
      adminLastName = "Lövgren";
      gmailUserName = "marcuslvgrn@gmail.com";
    };
    services.desktopManager.gnome.enable = true;
    virtualisation.vmware.guest.enable = true;
  };
  
}

