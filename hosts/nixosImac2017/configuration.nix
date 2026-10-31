# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  #  lib,
  #  hostSettings,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    ssd.enable = true;
    #deskflow.enable = true;
    services.desktopManager.gnome.enable = true;
    #services.teamviewer.enable = true;
    #virtualisation.virtualbox.host.enable = true;

    #nextcloud-client.enable = true;
    #bitwarden-desktop.enable = true;
    boot = {
      #kernelParams = [
      #  #"amdgpu.dc=1"
      #  #"amdgpu.exp_res_limit=1"
      #  "video=eDP-1:2560x1440@60e"
      #];
      initrd.kernelModules = [
        #"applespi"
        #"spi_pxa2xx_platform"
        #"intel_lpss_pci"
        #"applesmc"
      ];
      kernelParams = [
        #"intel_iommu=on"
        "video=eDP-1:2560x1440@60e"
      ];
    };
    boot.extraModulePackages = [
      (pkgs.callPackage ./cs8409-module.nix {
        kernel = config.boot.kernelPackages.kernel;
      })
    ];
    boot.kernelModules = [ "snd_hda_codec_cs8409" ];
    environment.systemPackages = (
      with pkgs;
      [
        #    fprintd
        #    libva-utils
        #    vdpauinfo
        #    intel-gpu-tools
        #    cifs-utils
      ]
    )
    #      ++ (with pkgs-stable; [])
    #      ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
    ;

    #services.fprintd.enable = true;
    #services.fprintd.tod.enable = true;
    #services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

    # Autologin a user
    services.displayManager = {
      autoLogin.enable = false;
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

    #environment.sessionVariables = {
    #  LIBVA_DRIVER_NAME = "iHD";
    #  VDPAU_DRIVER = "va_gl";
    #};
    hardware.graphics = {
      enable = true;
      extraPackages = (
        with pkgs;
        [
          #      intel-media-driver
          #      intel-vaapi-driver
          #      libvdpau-va-gl
          #      vpl-gpu-rt
        ]
      )
      #        ++ (with pkgs-stable; [])
      #        ++ (with pkgs-unstable; [])
      # Uncomment either block above to pin specific packages to stable or unstable
      # regardless of the host's defaultPkgChannel setting (see technitium for an example).
      ;
    };
  };
}
