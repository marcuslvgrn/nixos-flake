{
  ...
}:

{
  imports = [
    ./hw.nix
  ];

  services.desktopManager.gnome.enable = true;

  startFirefoxAtLogin = true;

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };

  #Power management
  #powerManagement.enable = true;
  #services.power-profiles-daemon.enable = true;
  ##In Gnome, power key behavior is set by the settings app!
  #services.logind = {
  #  #    settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  #  settings.Login.HandleLidSwitch = "hibernate";
  #  #    settings.Login.HandlePowerKey = "hibernate";
  #  settings.Login.HandlePowerKeyLongPress = "poweroff";
  #};

  #  # Suspend first
  #  boot.kernelParams = ["mem_sleep_default=deep"];
  #
  #  # Define time delay for hibernation
  #  systemd.sleep.extraConfig = ''
  #    HibernateDelaySec=30m
  #    SuspendState=mem
  #  '';

  #services.udev.extraRules = ''
  #  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  #'';
}
