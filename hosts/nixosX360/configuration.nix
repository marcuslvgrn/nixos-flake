# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  #  config,
  #  lib,
  hostCfg,
  #  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
  ];

  config = {
    services.desktopManager.gnome.enable = true;
    virtualisation.virtualbox.host.enable = true;
    ssdEnable = true;

    #  boot.loader.grub.extraEntries = ''
    #    menuentry "Arch" {
    #      set root=(hd0,gpt1)
    #      chainloader /efi/grub/grubx64.efi
    #    }
    #  '';

    swapDevices = [
      {
        device = "/swap/swapfile";
        size = 8 * 1024;
      }
    ];

    # Autologin a user
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "lovgren";
    };

    #Specify hibernation options
    boot.kernelParams = [
      "resume_offset=8628224"
      "kvm.enable_virt_at_load=0"
    ];
    boot.resumeDevice = "/dev/disk/by-uuid/4aabc80c-9556-4323-862e-17a0452e695a";

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
