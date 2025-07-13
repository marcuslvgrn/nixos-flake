# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, disko, hostname, home-manager, ... }:

{
  imports = [
    ../../common/grub.nix
    ../../common/openssh.nix
    ../../common/users.nix
    ../../common/configuration.nix
    ../../common/virtualbox.nix
    ./disk-config.nix
  ];

  networking.useDHCP = lib.mkDefault true;

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4 * 1024;
  }];

  networking.hostName = hostname;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager = { enable = true; };

  users.users.root.initialPassword = "test";
  users.users.root.openssh.authorizedKeys.keyFiles = [
    #this is populated by sops-nix
    /run/secrets/ssh/authorized_keys/root
  ];
  users.users.lovgren.openssh.authorizedKeys.keyFiles = [
    #this is populated by sops-nix
    /run/secrets/ssh/authorized_keys/lovgren
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}

