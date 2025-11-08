{ pkgs, inputs, config, ... }:

{
  #load the module
  imports = [
    inputs.sops-nix.nixosModules.sops
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
    secrets."nextcloud.env" = {
#      owner = "nextcloud";
#      group = "keys";
    };
    secrets."passwords/lovgren" = {
      #make password available to users module, can then be used with hashedPasswordFile during user creation
      neededForUsers = true;
    };
    secrets."passwords/gerd" = {
      #make password available to users module, can then be used with hashedPasswordFile during user creation
      neededForUsers = true;
    };
    secrets."passwords/root" = {
      #make password available to users module, can then be used with hashedPasswordFile during user creation
      neededForUsers = true;
    };
    secrets."dynv6-credentials" = {
#      owner = "nginx";
#      group = "nginx";
    };
    secrets."vaultwarden-env" = {};
  };
}
