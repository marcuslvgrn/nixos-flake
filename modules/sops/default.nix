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

    # Both host key (for nixos-anywhere) and root key (for sops calls)
    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/root/.ssh/id_ed25519"
    ];

    # Global secrets needed on every host.
    # Service-specific secrets are declared in their respective modules.
    secrets."wifi.env" = { };
    secrets."ssh/keys/root/id_ed25519.pub" = {
      path = "/root/.ssh/id_ed25519.pub";
      owner = "root";
      group = "root";
      mode = "0444";
    };
    secrets."ssh/keys/root/id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
      owner = "root";
      group = "root";
      mode = "0400";
    };
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
    # make password available to users module for hashedPasswordFile
    secrets."passwords/lovgren" = {
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

  # SOPS CLI needs the SSH host key converted back to its age identity.
  environment.variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /root/.ssh/id_ed25519";
  security.sudo.extraConfig = ''
    Defaults env_keep += "SOPS_AGE_KEY_CMD"
  '';

}
