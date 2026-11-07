{
  ...
}:
{
  imports = [
    ./hw.nix
    ./disk-config.nix
  ];

  services.desktopManager.gnome.enable = true;
  omarchy = {
    enable = false;
    managedPackagesFile =
      if builtins.pathExists ./omarchy-packages.json then ./omarchy-packages.json else null;
    plymouth.enable = false;
  };

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
