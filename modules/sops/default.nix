{
  inputs,
  ...
}:

{
  # Load the module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./root-secrets.yaml;
    defaultSopsFormat = "yaml";

    #age.keyFile = "/root/.config/sops/age/keys.txt";
    age.keyFile = null;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Global secrets needed on every host.
    # Service-specific secrets are declared in their respective modules.
    secrets."wifi.env" = { };
    secrets."ssh/keys/lovgren/id_ed25519.pub" = {
      path = "/home/lovgren/.ssh/id_ed25519.pub";
      owner = "lovgren";
      group = "users";
      mode = "0444";
    };
    secrets."ssh/keys/lovgren/id_ed25519" = {
      path = "/home/lovgren/.ssh/id_ed25519";
      owner = "lovgren";
      group = "users";
      mode = "0400";
    };
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

  systemd.tmpfiles.rules = [
    "d /home/lovgren/.ssh 0700 lovgren users -"
  ];
}
