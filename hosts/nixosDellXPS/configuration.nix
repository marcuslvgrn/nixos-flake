# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, cfg, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hosts/nixosMinimal/configuration.nix
    ../../common/gnome.nix
    ../../common/ssd.nix
    ../../common/virtualbox-host.nix
    ../../services/ath11k-suspend.nix
    ../../services/bluetooth-suspend.nix
  ];

  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/grub/grubx64.efi
    }
  '';

  swapDevices = [{
    device = "/swap/swapfile";
    size = 16 * 1024;
  }];

  environment.systemPackages =
    (with cfgPkgs; [
      fprintd
      libva-utils
      vdpauinfo
      intel-gpu-tools
      bottles
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = cfgPkgs.libfprint-2-tod1-goodix;

  # Autologin a user
  services.displayManager = { autoLogin.enable = false; };

  #Specify hibernation options
#    "resume=UUID=0a718fe8-0e53-40b6-82aa-c1829c2c4ead"
  boot.kernelParams = [
    "resume_offset=533760"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

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

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };
  hardware.graphics = {
    enable = true;
    extraPackages =
      (with cfgPkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        vpl-gpu-rt
      ])
      ++
      (with pkgs-stable; [
        
      ])
      ++
      (with pkgs-unstable; [
        
      ]);
  };
}
