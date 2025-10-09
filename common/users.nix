{ inputs, config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    #load the home manager module
    inputs.home-manager.nixosModules.home-manager
  ];

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

  home-manager = {
    #expose variables to loaded home-manager modules
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    #home manager user definition
    users.lovgren = {
      imports = [ ../home-manager/lovgren.nix ];
    };
    #home manager root definition
    users.root = {
      imports = [ ../home-manager/root.nix ];
    };
  };

}
