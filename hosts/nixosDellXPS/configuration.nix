{
  # pkgs,
  ...
}:

{
  imports = [
    # HW configuration
    ./hw.nix
  ];

  # Enable software KVM
  deskflow.enable = true;
  services.easyswitch = {
    enable = true;
    user = "lovgren";
  };

  # Use gnome as the desktop manager
  services.desktopManager.gnome.enable = true;
  omarchy = {
    enable = false;
    managedPackagesFile =
      if builtins.pathExists ./omarchy-packages.json then ./omarchy-packages.json else null;
    plymouth.enable = false;
  };

  # Enable teamviewer
  services.teamviewer.enable = false;
  # Enable virtualbox
  virtualisation.virtualbox.host.enable = true;
  # Enable nextcloud client
  nextcloud-client.enable = true;
  # Enable bitwarden desktop
  bitwarden-desktop.enable = true;

  # Install host specific packages
  #environment.systemPackages = (
  #  with pkgs;
  #  [
  #  ]
  #)
  #      ++ (with pkgs-stable; [])
  #      ++ (with pkgs-unstable; [])
  # Uncomment either block above to pin specific packages to stable or unstable
  # regardless of the host's defaultPkgChannel setting (see technitium for an example).
  #;

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = false;
  };

  #Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  #In Gnome, power key behavior is set by the settings app!
  services.logind = {
    #    settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    settings.Login.HandleLidSwitch = "hibernate";
    #    settings.Login.HandlePowerKey = "hibernate";
    settings.Login.HandlePowerKeyLongPress = "poweroff";
  };

}
