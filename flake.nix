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
  };
  
  outputs = inputs@{ self, ... }:
     let
       configurations = [
         #All machines, their hostnames and machine type
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
       #A function that takes a configuration (as above) as argument
       #and returns a nixosSystem
       mkConfig = cfg: let
         pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${cfg.system};
       in {
         name = cfg.hostname;
         value = inputs.nixpkgs.lib.nixosSystem {
           system = cfg.system;
           modules = [
             {
               imports = [
                 #load the host specific configuration
                 (./. + "/hosts" + ("/" + cfg.hostname) + "/configuration.nix")
               ];
             }
           ];
           #expose variables to loaded modules
           specialArgs = {
             #var = value;
             #expose variables from this scope to imported modules with same name
             inherit inputs cfg pkgs-unstable;
           };
         };
       };
     in {
       #Assemble all the system configurations, looping through the variable configurations
       #By calling the function mkConfig on each entry
       nixosConfigurations = builtins.listToAttrs (map mkConfig configurations);
     };
}
