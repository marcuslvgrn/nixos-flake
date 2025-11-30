{
  description = "Marcus nix config";

  inputs = {
    #Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    #Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Gather system information
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
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };
  
  outputs = inputs@{ self, ... }:
     let
       configurations = [
         #All machines, their hostnames and machine type
         { hostname = "nixosDellXPS";
           system = "x86_64-linux";
           isStable = false; }
         { hostname = "nixosX360";
           system = "x86_64-linux";
           isStable = false; }
         { hostname = "nixosVMWareMinimal";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosVMWareGnome";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosVBoxMinimal";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosVBoxGnome";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosASUS";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosTranfor";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosMinimal";
           system = "x86_64-linux";
           isStable = true; }
         { hostname = "nixosImac";
           system = "x86_64-linux";
           isStable = true; }
       ];
       #A function that takes a configuration (as above) as argument
       #and returns a nixosSystem
       mkConfig = cfg: let
         pkgs-stable = import inputs.nixpkgs {
           system = cfg.system;
           config.allowUnfree = true;
         };
         pkgs-unstable = import inputs.nixpkgs-unstable {
           system = cfg.system;
           config.allowUnfree = true;
         };
       in {
         name = cfg.hostname;
         value = (
           if cfg.isStable
           then inputs.nixpkgs
           else inputs.nixpkgs-unstable
         ).lib.nixosSystem {
           system = cfg.system;
           modules = [
             #nix-flatpak
             inputs.nix-flatpak.nixosModules.nix-flatpak
             # Enable Home Manager
             (if cfg.isStable then
               inputs.home-manager.nixosModules.home-manager
              else
                inputs.home-manager-unstable.nixosModules.home-manager
             )
             # Host-specific configuration
             ./hosts/${cfg.hostname}/configuration.nix
             # Set allowUnfree globally
             {
               nixpkgs.config.allowUnfree = true;
             }
           ];

           #expose variables to loaded modules
           specialArgs = {
#             cfgPkgs = if cfg.isStable then pkgs-stable else pkgs-unstable;
             #expose variables from this scope to imported modules with same name
             inherit inputs cfg pkgs-stable pkgs-unstable;
           };
         };
       };
     in {
       #Assemble all the system configurations, looping through the variable configurations
       #By calling the function mkConfig on each entry
       nixosConfigurations = builtins.listToAttrs (map mkConfig configurations);
     };
}
