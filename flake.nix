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
      # Auto-detect host folders
      hostFolders = builtins.attrNames (builtins.readDir ./hosts);

      # Build host configurations with defaults
      defaultHostCfgs = map (hostname:
        let
          platform = if builtins.match "darwin.*" (hostname) != null
                     then "darwin"
                     else "nixos";
          system   = if platform == "nixos" then "x86_64-linux" else "x86_64-darwin";
          isStable = true;
          gnomeEnable = false;
        in { inherit hostname platform system isStable gnomeEnable; }
      ) hostFolders;

      # Per-host overrides
      overrides = {
        "nixosX360" = { isStable = false; gnomeEnable = true;};
        "nixosDellXPS" = { isStable = false; gnomeEnable = true;};
      };
      
      # Apply overrides
      overriddenHostCfgs = map (perHostDefaultCfg:
        let
          #make a list of overrides from the attributes specified in the overrides set
          #only with a newer nix that takes three arguments, I should update nix (use unstable)
#          perHostOverrides = builtins.getAttr perHostDefaultCfg.hostname overrides {};
          perHostOverrides =
            if builtins.hasAttr perHostDefaultCfg.hostname overrides
            then builtins.getAttr perHostDefaultCfg.hostname overrides
            else {};
        in
          #merge the defaultConfigs and hostOverrides
          perHostDefaultCfg // perHostOverrides
      ) defaultHostCfgs;

      # Split by platform
      nixosHosts = builtins.filter (c: c.platform == "nixos") overriddenHostCfgs;
      darwinHosts = builtins.filter (c: c.platform == "darwin") overriddenHostCfgs;

      mkSystem = hostCfg:
        let
          overlays = [
            inputs.nur.overlays.default
          ];
          allowUnfree = true;
          # ------------------------------------------------------------
          # Define nixpkgs variants for stable and unstable
          # ------------------------------------------------------------
          pkgs-stable = import inputs.nixpkgs {
            system = hostCfg.system;
            config.allowUnfree = allowUnfree;
            inherit overlays;
          };
          pkgs-unstable = import inputs.nixpkgs-unstable {
            system = hostCfg.system;
            config.allowUnfree = allowUnfree;
            inherit overlays;
          };
          # This is the chosen nixpkg based on configuration
          pkgs = if hostCfg.isStable then pkgs-stable else pkgs-unstable;
          #For choosing the correc input libs based on configuration
          inputLib =
            if hostCfg.isStable then
              if hostCfg.platform == "nixos" then inputs.nixpkgs.lib else inputs.nix-darwin.lib
            else
              if hostCfg.platform == "nixos" then inputs.nixpkgs-unstable.lib else inputs.nix-darwin-unstable.lib;
          #Choose the right home manager module
          homeManagerModule =
            #this returns the correct darwinModules or nixosModules from inputs.home-manager,
            #like inputs.home-manager.nixosModules.home-manager, also for stable or unstable
            if hostCfg.isStable then (builtins.getAttr (hostCfg.platform + "Modules") inputs.home-manager).home-manager
            else (builtins.getAttr (hostCfg.platform + "Modules") inputs.home-manager-unstable).home-manager;
        in {
          name = hostCfg.hostname;
          value =
            # Darwin host
            if hostCfg.platform == "darwin" then
              inputLib.darwinSystem {
                system = hostCfg.system;
                modules = [
                  homeManagerModule
                  ./hosts/${hostCfg.hostname}/configuration.nix
                ];
                specialArgs = {
                  inherit inputs self hostCfg pkgs pkgs-stable pkgs-unstable;
                };
              }
            else
              # NixOS host
              inputLib.nixosSystem {
                inherit pkgs;
                system = hostCfg.system;
                modules = [
                  homeManagerModule
                  ./hosts/${hostCfg.hostname}/configuration.nix
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                ];
                specialArgs = {
                  inherit inputs hostCfg pkgs-stable pkgs-unstable;
                };
              };
        };
    in {
      #Assemble all the system configurations, looping through the variable configurations
      #by calling the function mkSystem on each entry. Separate nixos and darwin
      nixosConfigurations = builtins.listToAttrs (map mkSystem nixosHosts);
      darwinConfigurations = builtins.listToAttrs (map mkSystem darwinHosts);
      extraSpecialArgs = {

      };
    };
}
