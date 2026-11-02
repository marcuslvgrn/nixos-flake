{
  ...
}:
{
  imports = [
    ./hw.nix
    ./disk-config.nix
  ];

  services.desktopManager.gnome.enable = true;
  ssd.enable = true;
  kodi.enable = true;

  extraFavoriteApps = [
    "kodi.desktop"
  ];

  extraFirefoxExtensions = [
    "enhanced-h264ify"
  ];

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };

}
