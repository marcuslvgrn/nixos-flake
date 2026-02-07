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
  
  #virtualisation.virtualbox.host = lib.mkIf config.virtualisation.virtualbox.host.enable {
  #  enableExtensionPack = true;
  #};

  #Host extensions (USB forwarding) - causes frequent rebuilds
  users.extraGroups.vboxusers = lib.mkIf config.virtualisation.virtualbox.host.enable {
    members = [ "lovgren" ];
  };
}
    
