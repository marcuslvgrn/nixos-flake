# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/gnome.nix
    ../../common/ssd.nix
    ./hardware-configuration.nix
#    ./disk-config.nix
  ];

#  boot.loader.grub.extraEntries = ''
#    menuentry "Arch" {
#      set root=(hd0,gpt1)
#      chainloader /efi/grub/grubx64.efi
#    }
#  '';

  swapDevices = [{
    device = "/swap/swapfile";
    size = 12 * 1024;
  }];

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
  #Specify hibernation options
#  boot.kernelParams = [
#    "resume_offset=533760"
#    "resume=UUID=68beb70a-0619-4393-8956-ce7d4658ae5d"
#    "kvm.enable_virt_at_load=0"
#  ];
#  boot.resumeDevice = "/dev/disk/by-uuid/68beb70a-0619-4393-8956-ce7d4658ae5d";

  #Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  #  # Suspend first then hibernate when closing the lid
  #  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitch = "hibernate";
  #  # Hibernate on power button pressed
  services.logind.powerKey = "hibernate";
  services.logind.powerKeyLongPress = "poweroff";

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

