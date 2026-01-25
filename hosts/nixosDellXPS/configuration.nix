# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, hostCfg, pkgs, pkgs-stable, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/ssd.nix
    ../../common/virtualbox-host.nix
    ../../services/ath11k-suspend.nix
    ../../services/bluetooth-suspend.nix
  ];

  config = {
    desktop = {
      desktopManagers = {
        gnome = {
          enable = true;
        };
      };
    };
  };
  
  boot.loader.grub.extraEntries = ''
    menuentry "Arch" {
      set root=(hd0,gpt1)
      chainloader /efi/arch/grubx64.efi
    }
  '';

  swapDevices = [{
    device = "/swap/swapfile";
    size = 16 * 1024;
  }];

  fileSystems."/mnt/nixosTranfor" = {
    device = "//nixosTranfor/data";
    fsType = "cifs";
    options = [
      "user,users"
      "uid=1000,gid=100"
      "file_mode=0664,dir_mode=0775"
    ];
  };

  environment.systemPackages =
    (with pkgs; [
      fprintd
      libva-utils
      vdpauinfo
      intel-gpu-tools
      bottles
      cifs-utils
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Autologin a user
  services.displayManager = { autoLogin.enable = false; };

  #Specify hibernation options
  boot.kernelParams = [
    "resume_offset=4838900"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

  #Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  #In Gnome, power key behavior is set by the settings app!
  services.logind = if hostCfg.isStable then {
#    lidSwitch = "suspend-then-hibernate";
    lidSwitch = "hibernate";
#    powerKey = "hibernate";
    powerKeyLongPress = "poweroff";
  } else {
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
    extraPackages =
      (with pkgs; [
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
