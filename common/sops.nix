{ pkgs, inputs, config, hostname, ... }:

{
  imports = [
    #inputs.sops-nix.nixosModules.sops
  ];

  sops = { 
    defaultSopsFile = ../secrets/root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets."wifi.env" = { };
    secrets."ssh/authorized_keys/lovgren" = {};
    secrets."ssh/authorized_keys/root" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519" = {};
    secrets."ssh/keys/nixosVMWareGnome/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWareGnome/id_ed25519" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519" = {};
    secrets."ssh/keys/nixosVBoxGnome/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVBoxGnome/id_ed25519" = {};
    secrets."ssh/keys/nixosDellXPS/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosDellXPS/id_ed25519" = {};
    secrets."ssh/keys/nixosX360/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosX360/id_ed25519" = {};
    secrets."ssh/keys/nixosASUS/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosASUS/id_ed25519" = {};
    secrets."age/keys.txt" = {};
#    secrets."passwords/lovgren" = {};
#    secrets."passwords/root" = {};
  };
}
