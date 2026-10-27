{
  #  config,
  #  lib,
  #  pkgs,
  # inputs,
  ...
}:
#with lib;
{
  imports = [
    #./hardware-configuration.nix
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
    diskoConfig.enable = true;
    diskoConfig.device = "/dev/sda";
    services.desktopManager.gnome.enable = true;
    virtualisation.vmware.guest.enable = true;
  };
}
