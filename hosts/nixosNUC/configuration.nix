# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, hostCfg, pkgs, pkgs-stable, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../common/configuration.nix
#    ../../services/bluetooth-suspend.nix
  ];

  services.desktopManager.gnome.enable = true;
  virtualisation.virtualbox.host.enable = true;
  config.ssd.enable = true;
  
#  boot.loader.grub.extraEntries = ''
#    menuentry "Arch" {
#      set root=(hd0,gpt1)
#      chainloader /efi/arch/grubx64.efi
#    }
#  '';

  environment.systemPackages =
    (with pkgs; [
#      libva-utils
#      vdpauinfo
#      intel-gpu-tools
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

  # Autologin a user
  services.displayManager = { autoLogin.enable = false; };

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
#  environment.sessionVariables = {
#    LIBVA_DRIVER_NAME = "iHD";
#    VDPAU_DRIVER = "va_gl";
#  };
#  hardware.graphics = {
#    enable = true;
#    extraPackages =
#      (with pkgs; [
#        intel-media-driver
#        intel-vaapi-driver
#        libvdpau-va-gl
#        vpl-gpu-rt
#      ])
#      ++
#      (with pkgs-stable; [
#        
#      ])
#      ++
#      (with pkgs-unstable; [
#        
#      ]);
#  };
}
