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
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Flake utils, for example automatic machine type identification
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin-unstable = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  
  outputs = inputs@{ self, ... }:
     let
       configurations = [
         #All machines, their hostnames and machine type
         { hostname = "nixosDellXPS";
           system = "x86_64-linux";
           isStable = false;
           gnomeEnable = true;
           platform = "nixos";
         }
         { hostname = "nixosX360";
           system = "x86_64-linux";
           isStable = false; 
           gnomeEnable = true;
           platform = "nixos";
         }
         { hostname = "nixosVMWareMinimal";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = false;
           platform = "nixos";
         }
         { hostname = "nixosVMWareGnome";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = true;
           platform = "nixos";
         }
         { hostname = "nixosVBoxMinimal";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = false;
           platform = "nixos";
         }
         { hostname = "nixosVBoxGnome";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = true;
           platform = "nixos";
         }
         { hostname = "nixosASUS";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = false;
           platform = "nixos";
         }
         { hostname = "nixosTranfor";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = false;
           platform = "nixos";
         }
         { hostname = "nixosMinimal";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = false;
           platform = "nixos";
         }
         { hostname = "nixosImac";
           system = "x86_64-linux";
           isStable = true; 
           gnomeEnable = true;
           platform = "nixos";
         }
         { hostname = "Marcus-iMac";
           system = "x86_64-darwin";
           isStable = false; 
           gnomeEnable = false;
           platform = "darwin";
         }
         { hostname = "nixosNUC";
           system = "x86_64-linux";
           isStable = false; 
           gnomeEnable = true;
           platform = "nixos";
         }
       ];

       mkSystem = cfg:
         let
           overlays = [
             inputs.nur.overlays.default
           ];
           allowUnfree = true;
           # ------------------------------------------------------------
           # Define nixpkgs variants
           # ------------------------------------------------------------
           pkgs-stable = import inputs.nixpkgs {
             system = cfg.system;
             config.allowUnfree = allowUnfree;
             inherit overlays;
           };
           pkgs-unstable = import inputs.nixpkgs-unstable {
             system = cfg.system;
             config.allowUnfree = allowUnfree;
             inherit overlays;
           };
           pkgs = if cfg.isStable then pkgs-stable else pkgs-unstable;
           inputLib =
             if cfg.isStable then
               if cfg.platform == "nixos" then inputs.nixpkgs.lib else inputs.nix-darwin.lib
             else
               #note, no unstable here...
               if cfg.platform == "nixos" then inputs.nixpkgs-unstable.lib else inputs.nix-darwin-unstable.lib;
           homeManagerModule =
             #this returns the correct darwinModules or nixosModules from inputs.home-manager,
             #like inputs.home-manager.nixosModules.home-manager, also for stable or unstable
             if cfg.isStable then (builtins.getAttr (cfg.platform + "Modules") inputs.home-manager).home-manager
             else (builtins.getAttr (cfg.platform + "Modules") inputs.home-manager-unstable).home-manager;
         in {
           name = cfg.hostname;
           value =
             # Darwin host
             if cfg.platform == "darwin" then
               inputLib.darwinSystem {
                 system = cfg.system;
                 modules = [
                   homeManagerModule
                   ./hosts/${cfg.hostname}/configuration.nix
                 ];
                 specialArgs = {
                   inherit inputs self cfg pkgs pkgs-stable pkgs-unstable;
                 };
               }
             else
               # NixOS host
               inputLib.nixosSystem {
                 inherit pkgs;
                 system = cfg.system;
                 modules = [
                   homeManagerModule
                   ./hosts/${cfg.hostname}/configuration.nix
                   inputs.nix-flatpak.nixosModules.nix-flatpak
                 ];
                 specialArgs = {
                   inherit inputs cfg pkgs-stable pkgs-unstable;
                 };
               };
         };
     in
       let
         nixosHosts = builtins.filter (c: c.platform == "nixos") configurations;
         darwinHosts = builtins.filter (c: c.platform == "darwin") configurations;
       in
         {
           #Assemble all the system configurations, looping through the variable configurations
           #by calling the function mkSystem on each entry. Separate nixos and darwin
           nixosConfigurations = builtins.listToAttrs (map mkSystem nixosHosts);
           darwinConfigurations = builtins.listToAttrs (map mkSystem darwinHosts);
         };
}
