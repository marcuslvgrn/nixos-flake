# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  #  config,
  #  lib,
  #  hostCfg,
  #  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    services.desktopManager.gnome.enable = true;
    virtualisation.virtualbox.host.enable = true;
    ssdEnable = true;

    # Autologin a user
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "lovgren";
    };

    #Power management
    powerManagement.enable = true;
    services.power-profiles-daemon.enable = true;
    services.logind = {
      settings.Login.HandleLidSwitch = "hibernate";
      settings.Login.HandlePowerKey = "ignore";
      settings.Login.HandlePowerKeyLongPress = "poweroff";
    };

    #  # Suspend first
    #  boot.kernelParams = ["mem_sleep_default=deep"];
    #
    #  # Define time delay for hibernation
    #  systemd.sleep.extraConfig = ''
    #    HibernateDelaySec=30m
    #    SuspendState=mem
    #  '';

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled" 
    '';

    #  environment.sessionVariables = {
    #    LIBVA_DRIVER_NAME = "iHD";
    #    VDPAU_DRIVER = "va_gl";
    #  };
    #  hardware.graphics = {
    #    enable = true;
    #    extraPackages = with pkgs; [
    #      intel-media-driver
    #      intel-vaapi-driver
    #      libvdpau-va-gl
    #      vpl-gpu-rt
    #    ];
    #  };
  };
}
