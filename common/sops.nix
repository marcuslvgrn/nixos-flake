{ pkgs, inputs, config, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = { 
    defaultSopsFile = ../secrets/root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";
    
    secrets."wifi.env" = { };
  };
}
