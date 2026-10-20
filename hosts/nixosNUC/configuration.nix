# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  #pkgs-stable,
  #pkgs-unstable,
  #inputs,
  ...
}:
with lib;
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    #    ../../services/bluetooth-suspend.nix
  ];

  config = {
    services.desktopManager.gnome.enable = true;
    services.xserver.desktopManager.kodi.enable = true;
    ssd.enable = true;

    kodi.enable = true;

    extraFavoriteApps = [
      "kodi.desktop"
    ];

    extraFirefoxExtensions = [
      "enhanced-h264ify"
    ];

    #  boot.loader.grub.extraEntries = ''
    #    menuentry "Arch" {
    #      set root=(hd0,gpt1)
    #      chainloader /efi/arch/grubx64.efi
    #    }
    #  '';

    environment.systemPackages = (
      with pkgs;
      [
        libva-utils
        vdpauinfo
        intel-gpu-tools
        #])
        # Populate either block to pin specific packages to stable or unstable
        # regardless of the host's isStable setting (see technitium for an example).
        #++ (with pkgs-stable; [
        #
        #])
        #++ (with pkgs-unstable; [
        #
      ]
    );

    # Autologin a user
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "lovgren";
    };

    #Specify hibernation options
    boot.kernelParams = [
      "resume_offset=533760"
      "kvm.enable_virt_at_load=0"
    ];
    boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

    #  #Power management
    #  powerManagement.enable = true;
    #  services.power-profiles-daemon.enable = true;
    #  #In Gnome, power key behavior is set by the settings app!
    #  services.logind = if hostCfg.isStable then {
    ##    lidSwitch = "suspend-then-hibernate";
    #    lidSwitch = "hibernate";
    ##    powerKey = "hibernate";
    #    powerKeyLongPress = "poweroff";
    #  } else {
    ##    settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    #    settings.Login.HandleLidSwitch = "hibernate";
    ##    settings.Login.HandlePowerKey = "hibernate";
    #    settings.Login.HandlePowerKeyLongPress = "poweroff";
    #  };

    #  # Suspend first
    #  boot.kernelParams = ["mem_sleep_default=deep"];
    #
    #  # Define time delay for hibernation
    #  systemd.sleep.extraConfig = ''
    #    HibernateDelaySec=30m
    #    SuspendState=mem
    #  '';

    #  services.udev.extraRules = ''
    #    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
    #  '';
    #
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
      VDPAU_DRIVER = "va_gl";
    };
    hardware.graphics = {
      enable = true;
      extraPackages = (
        with pkgs;
        [
          #intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
          #vpl-gpu-rt
          #])
          #++ (with pkgs-stable; [
          #
          #       ])
          #      ++ (with pkgs-unstable; [
          #
        ]
      );
    };
  };
}
