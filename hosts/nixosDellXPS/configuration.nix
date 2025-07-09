# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, hostname, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/gnome.nix
    ../../common/grub.nix
    ../../common/networkmanager.nix
    ../../common/openssh.nix
    ../../common/users.nix
    ../../common/sops.nix
    ../../common/ssd.nix
    ../../services/ath11k-suspend.nix
    ../../services/bluetooth-suspend.nix
  ];

  networking.hostName = hostname;

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

  #Enable fingerprint reader
  environment.systemPackages = with pkgs; [ fprintd ];
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Autologin a user
  services.displayManager = { autoLogin.enable = false; };

  #Specify hibernation options
  boot.kernelParams = [
    "resume_offset=533760"
    "resume=UUID=dcabbd78-7298-431a-8877-cabf3a77a6e2"
    "kvm.enable_virt_at_load=0"
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/dcabbd78-7298-431a-8877-cabf3a77a6e2";

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

  # Includes the Wi-Fi and Bluetooth firmware for the QCA6390.
  hardware.enableRedistributableFirmware = true;

}

