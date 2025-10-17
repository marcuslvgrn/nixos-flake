{ inputs, config, lib, cfgPkgs, pkgs-stable, pkgs-unstable, ... }:

{
  imports = [
    ../../hosts/nixosMinimal/configuration.nix
    ./disk-config.nix
  ];

  #Packages only installed on this host
  environment.systemPackages =
      (with cfgPkgs; [
        docker-compose
      ])
      ++
      (with pkgs-stable; [
        
      ])
      ++
      (with pkgs-unstable; [
        
      ]); 
}

