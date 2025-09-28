{
  description = "Marcus nix config";

  inputs = {
    #Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    #Nix user repository
    nur = {
      url = "nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Flake utils, for example automatic machine type identification
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, disko,
                     nixos-facter-modules, sops-nix, flake-utils, ... }:
     let
       configurations = [
         #All machines, their hostnames and machine type
         { hostname = "nixosVMWareGnome"; system = "x86_64-linux"; }
         { hostname = "nixosDellXPS"; system = "x86_64-linux"; }
         { hostname = "nixosX360"; system = "x86_64-linux"; }
         { hostname = "nixosVMWareMinimal"; system = "x86_64-linux"; }
         { hostname = "nixosVMWareGnome"; system = "x86_64-linux"; }
         { hostname = "nixosVBoxMinimal"; system = "x86_64-linux"; }
         { hostname = "nixosVBoxGnome"; system = "x86_64-linux"; }
         { hostname = "nixosASUS"; system = "x86_64-linux"; }
         { hostname = "nixosTranfor"; system = "x86_64-linux"; }
         { hostname = "nixosMinimal"; system = "x86_64-linux"; }
         { hostname = "nixosImac"; system = "x86_64-linux"; }
       ];
       mkConfig = cfg: {
         name = cfg.hostname;
         networking.hostname = cfg.hostname;
         value = nixpkgs.lib.nixosSystem {
           system = cfg.system;
           modules = [
             {
               imports = [
                 #load the host specific configuration
                 (./. + "/hosts" + ("/" + cfg.hostname) + "/configuration.nix")
                 #load the sops-nix module
                 sops-nix.nixosModules.sops
                 #load the disko module
                 disko.nixosModules.disko
                 #load the home manager module
                 home-manager.nixosModules.home-manager
               ];
               #home manager user definition
               home-manager.users.lovgren = {
                 imports = [ ./home-manager/lovgren.nix ];
               };
               #home manager root definition
               home-manager.users.root = {
                 imports = [ ./home-manager/root.nix ];
#                 {
                   # Optionally, use home-manager.extraSpecialArgs to pass
                   # arguments to home.nix
#                   home-manager.extraSpecialArgs = { inherit inputs; };
                   #               home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };
#                 };
               };
             }
           ];
           #expose variables to loaded modules
           specialArgs = {
             hostname = cfg.hostname;
             pkgs-unstable = nixpkgs-unstable.legacyPackages.${cfg.system};
             #               inherit inputs home-manager cfg disko pkgs-unstable;
           };
         };
       };
     in {
       nixosConfigurations = builtins.listToAttrs (map mkConfig configurations);
     };
}
