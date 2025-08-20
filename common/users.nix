{ inputs, config, lib, pkgs, ... }:

{
  users.users.lovgren = {
    isNormalUser = true;
    description = "Marcus Lövgren";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
    home = "/home/lovgren";
    initialHashedPassword = "$y$j9T$S649krHeSXw6y3v0QOEUZ/$C8FV.4gjcybfSjjtLWtSy/HSw0tCA9TEWsGI/iD6pE/";
#    hashedPasswordFile = "${config.sops.secrets."passwords/lovgren".path}";
  };

  #Disable root login with password
  users.users.root.hashedPassword = "!";
}
