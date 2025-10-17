# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, cfg, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/gnome.nix
    ../../common/ssd.nix
  ];

  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/grub/grubx64.efi
    }
  '';

  swapDevices = [{
    device = "/dev/disk/by-uuid/5737d59b-b0f2-4de9-b4e3-b1f52b723ab0";
  }];

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
  #Specify hibernation options
  boot.kernelParams = [
    "resume=UUID=5737d59b-b0f2-4de9-b4e3-b1f52b723ab0"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/5737d59b-b0f2-4de9-b4e3-b1f52b723ab0";

  #Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind = if cfg.isStable then {
#    lidSwitch = "suspend-then-hibernate";
    lidSwitch = "hibernate";
    powerKey = "hibernate";
    powerKeyLongPress = "poweroff";
  } else {
#    settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    settings.Login.HandleLidSwitch = "hibernate";
    settings.Login.HandlePowerKey = "hibernate";
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
}

