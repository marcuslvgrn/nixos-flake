{ pkgs, inputs, config, ... }:

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
    secrets."ssh/keys/id_ed25519.pub" = {};
    secrets."ssh/keys/id_ed25519" = {};
    secrets."age/keys.txt" = {};
    secrets."passwords/lovgren" = {};
    secrets."passwords/root" = {};
  };
}
