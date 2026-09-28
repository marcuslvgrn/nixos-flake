# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  #  hostCfg,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    services.desktopManager.gnome.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.desktopManager.cosmic.enable = true;
    services.desktopManager.budgie.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;
    programs.nm-applet.indicator = lib.mkForce true;
    
    virtualisation.virtualbox.host.enable = true;
    ssdEnable = true;
    deskflow.enable = true;
    services.orca.enable = mkForce false;
    # Autologin a user
    services.displayManager = {
      defaultSession = "gnome";
      autoLogin.enable = false;
      #autoLogin.enable = true;
      autoLogin.user = "lovgren";
    };

    # resolve environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR conflict between gnome and budgie
    environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce (
      let
        cfg = config.services.desktopManager.gnome;

        nixos-background-light = pkgs.nixos-artwork.wallpapers.simple-blue;
        nixos-background-dark = pkgs.nixos-artwork.wallpapers.simple-dark-gray;

        flashbackEnabled = cfg.flashback.enableMetacity || lib.length cfg.flashback.customSessions > 0;

        nixos-gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
          inherit (cfg)
            extraGSettingsOverrides
            extraGSettingsOverridePackages
            favoriteAppsOverride
            ;
          inherit
            flashbackEnabled
            nixos-background-dark
            nixos-background-light
            ;
        };
      in
      "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
    );

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
