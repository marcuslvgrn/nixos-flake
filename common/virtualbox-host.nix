{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  #Enable virtualbox
  virtualisation.virtualbox.host.enable = true;
  #Host extensions (USB forwarding) - causes frequent rebuilds
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "lovgren" ];
}
