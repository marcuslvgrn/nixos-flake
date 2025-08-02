{ pkgs, inputs, config, ... }:

{
  imports = [
    #inputs.sops-nix.nixosModules.sops
  ];

  sops = { 
    defaultSopsFile = ../secrets/root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/age.key";
    
    secrets."wifi.env" = { };
    secrets."ssh/authorized_keys/lovgren" = {};
    secrets."ssh/authorized_keys/root" = {};
    secrets."ssh/keys/nixosVMWare/id_ed25519.pub" = {};
    secrets."ssh/keys/nixosVMWare/id_ed25519" = {};
#    secrets."passwords/lovgren" = {};
#    secrets."passwords/root" = {};
  };
}
