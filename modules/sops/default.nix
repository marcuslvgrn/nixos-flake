{
#  pkgs,
  inputs,
  config,
  ...
}:

{
  #load the module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/keys.txt";

    # Global secrets needed on every host.
    # Service-specific secrets are declared in their respective modules.
    secrets."wifi.env" = { };
    secrets."ssh/authorized_keys/lovgren" = { };
    secrets."ssh/authorized_keys/root" = { };
    secrets."ssh/keys/id_ed25519.pub" = { };
    secrets."ssh/keys/id_ed25519" = { };
    secrets."age/keys.txt" = { };
    secrets."passwords/lovgren" = {
      # make password available to users module for hashedPasswordFile
      neededForUsers = true;
    };
    secrets."passwords/gerd" = {
      neededForUsers = true;
    };
    secrets."passwords/root" = {
      neededForUsers = true;
    };
  };
}
