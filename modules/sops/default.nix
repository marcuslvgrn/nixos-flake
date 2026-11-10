{
  inputs,
  config,
  lib,
  ...
}:

let
  userData = import ../../common/users/userData.nix;
  normalUsers = lib.filter (
    username:
    let
      user = userData.users.${username} or { };
    in
    user.normalUser or false
  ) (config.userNames or [ ]);
  # sops-nix secrets consumed by common/users/default.nix as hashedPasswordFile.
  # Generate them only for normal accounts enabled on this host so other hosts
  # do not decrypt password hashes they never use.
  passwordSecrets = lib.genAttrs (map (username: "passwords/${username}") normalUsers) (_: {
    neededForUsers = true;
  });
in
{
  # Load the module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./root-secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    # Global secrets needed on every host.
    # Service-specific secrets are declared in their respective modules.
    secrets = {
      "wifi.env" = { };
      "ssh/keys/root/id_ed25519.pub" = {
        path = "/root/.ssh/id_ed25519.pub";
        owner = "root";
        group = "root";
        mode = "0444";
      };
      "ssh/keys/root/id_ed25519" = {
        path = "/root/.ssh/id_ed25519";
        owner = "root";
        group = "root";
        mode = "0400";
      };
      "ssh/keys/lovgren/id_ed25519.pub" = {
        path = "/home/lovgren/.ssh/id_ed25519.pub";
        owner = "lovgren";
        group = "users";
        mode = "0444";
      };
      "ssh/keys/lovgren/id_ed25519" = {
        path = "/home/lovgren/.ssh/id_ed25519";
        owner = "lovgren";
        group = "users";
        mode = "0400";
      };
    }
    // passwordSecrets;
  };

  systemd.tmpfiles.rules = [
    "d /home/lovgren/.ssh 0700 lovgren users -"
  ];

  # SOPS CLI needs the SSH host key converted back to its age identity.
  environment.variables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
  security.sudo.extraConfig = ''
    Defaults env_keep += "SOPS_AGE_KEY_CMD"
  '';

}
