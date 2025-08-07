{ pkgs, inputs, config, hostname, ... }:

{
  imports = [
    #inputs.sops-nix.nixosModules.sops
  ];

  sops = { 
    defaultSopsFile = ../secrets/root-secrets.yaml;
    defaultSopsFormat = "yaml";

    secrets."wifi.env" = { };
    secrets."ssh/authorized_keys/lovgren" = {};
    secrets."ssh/authorized_keys/root" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519" = {};
    secrets."age/keys/nixosVMWareMinimal/age.key" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519" = {};
    secrets."age/keys/nixosVBoxMinimal/age.key" = {};
#    secrets."passwords/lovgren" = {};
#    secrets."passwords/root" = {};
  };
}
