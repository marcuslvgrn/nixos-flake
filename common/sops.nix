{ pkgs, inputs, config, hostname, ... }:

{
  imports = [
    #inputs.sops-nix.nixosModules.sops
  ];

  sops = { 
    defaultSopsFile = ../secrets/root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/home/lovgren/.ssh/id_ed25519" ];
    age.generateKey = false;
    age.keyFile = "/root/.config/age/keys/age.key";

    secrets."wifi.env" = { };
    secrets."ssh/authorized_keys/lovgren" = {};
    secrets."ssh/authorized_keys/root" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWareMinimal/id_ed25519" = {};
    secrets."age/keys/nixosVMWareMinimal/age.key" = {};
    secrets."ssh/keys/nixosVMWareGnome/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWareGnome/id_ed25519" = {};
    secrets."age/keys/nixosVMWareGnome/age.key" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVBoxMinimal/id_ed25519" = {};
    secrets."age/keys/nixosVBoxMinimal/age.key" = {};
    secrets."ssh/keys/nixosVBoxGnome/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVBoxGnome/id_ed25519" = {};
    secrets."age/keys/nixosVBoxGnome/age.key" = {};
    secrets."ssh/keys/nixosDellXPS/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosDellXPS/id_ed25519" = {};
    secrets."age/keys/nixosDellXPS/age.key" = {};
    secrets."ssh/keys/nixosX360/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosX360/id_ed25519" = {};
    secrets."age/keys/nixosX360/age.key" = {};
    secrets."ssh/keys/nixosASUS/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosASUS/id_ed25519" = {};
    secrets."age/keys/nixosASUS/age.key" = {};
#    secrets."passwords/lovgren" = {};
#    secrets."passwords/root" = {};
  };
}
