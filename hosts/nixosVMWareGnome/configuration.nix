{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.moduleCfg;
in with lib;
{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/gnome.nix
    ../../common/vmware-guest.nix
#    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  moduleCfg = {
    passbolt = {
      enable = true;
      enableDdclient = true;
      enableNginxACME = true;
      enableNginxSSL = true;

      envFile = config.sops.secrets."passbolt-env".path;
      
      hostName = "mlpassbolt.dynv6.net";
      adminEmail = "marcus.lovgren@proton.me";
      gmailUserName = "marcuslvgrn@gmail.com";
    };
    programs = {
      firefox.enable = true;
      flatpak.enable = true;
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

