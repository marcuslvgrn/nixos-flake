{
  ...
}:

{
  imports = [
    ./hw.nix
  ];

  services.xserver.desktopManager.xfce.enable = true;

  diskoConfig.enable = true;
  diskoConfig.device = "/dev/sda";

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };

}
