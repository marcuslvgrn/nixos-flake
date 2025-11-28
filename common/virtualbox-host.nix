{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
    
    ]);

  #Enable virtualbox
  virtualisation.virtualbox.host.enable = true;
  #Host extensions (USB forwarding) - causes frequent rebuilds
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "lovgren" ];
}
