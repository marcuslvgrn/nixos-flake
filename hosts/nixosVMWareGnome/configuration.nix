{
  ...
}:

{
  imports = [
    ./hw.nix
  ];
  config = {
    passbolt = {
      enable = false;
      hostName = "mlpassbolt.dynv6.net";
      adminEmail = "marcus.lovgren@proton.me";
      adminFirstName = "Marcus";
      adminLastName = "Lövgren";
      gmailUserName = "marcuslvgrn@gmail.com";
    };
    services.desktopManager.gnome.enable = true;
  };
}
