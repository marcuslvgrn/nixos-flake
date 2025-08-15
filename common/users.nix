{ inputs, config, lib, pkgs, ... }:

{
  users.users.lovgren = {
    isNormalUser = true;
    description = "Marcus Lövgren";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
    home = "/home/lovgren";
    hashedPasswordFile = "${config.sops.secrets."passwords/lovgren".path}";
  };
}
