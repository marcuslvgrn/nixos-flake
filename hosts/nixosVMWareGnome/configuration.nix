{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.moduleCfg;
in with lib;
{
  imports = [
    ../../common/configuration.nix
    ../../common/vmware-guest.nix
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
    desktop = {
      desktopManagers = {
        gnome = {
          enable = true;
        };
      };
    };
  };
  
}

