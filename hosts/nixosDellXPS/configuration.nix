# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  #  config,
  #  lib,
  #  hostCfg,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../services/ath11k-suspend.nix
    ../../services/bluetooth-suspend.nix
  ];

  config = {
    ssdEnable = true;

    services.desktopManager.gnome.enable = true;
    virtualisation.virtualbox.host.enable = true;

    environment.systemPackages = (
      with pkgs;
      [
        fprintd
        libva-utils
        vdpauinfo
        intel-gpu-tools
        cifs-utils
      ]
    )
    #      ++ (with pkgs-stable; [])
    #      ++ (with pkgs-unstable; [])
    ;

    services.fprintd.enable = true;
    services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

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

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      VDPAU_DRIVER = "va_gl";
    };
    hardware.graphics = {
      enable = true;
      extraPackages = (
        with pkgs;
        [
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
          vpl-gpu-rt
        ]
      )
      #        ++ (with pkgs-stable; [])
      #        ++ (with pkgs-unstable; [])
      ;
    };
  };
}
