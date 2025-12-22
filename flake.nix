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
    # ------------------------------------------------------------
    # Select nixpkgs
    # ------------------------------------------------------------
    pkgs-stable = import inputs.nixpkgs {
      system = cfg.system;
      config.allowUnfree = true;
    };

    pkgs-unstable = import inputs.nixpkgs-unstable {
      system = cfg.system;
      config.allowUnfree = true;
    };

    pkgs =
      if cfg.isStable
      then pkgs-stable
      else pkgs-unstable;

#    isDarwin = cfg.platform == "darwin";
  in {
    name = cfg.hostname;
    value =
      if cfg.platform == "darwin" then
        inputs.nix-darwin.lib.darwinSystem {
          system = cfg.system;
          inherit pkgs;

          modules = [
            ./hosts/${cfg.hostname}/configuration.nix

            (if cfg.isStable
              then inputs.home-manager.darwinModules.home-manager
              else inputs.home-manager-unstable.darwinModules.home-manager
            )
          ];

          specialArgs = {
            inherit inputs self cfg pkgs-stable pkgs-unstable;
          };
        }
      else
        pkgs.lib.nixosSystem {
          system = cfg.system;

          modules = [
            inputs.nix-flatpak.nixosModules.nix-flatpak

            (if cfg.isStable
              then inputs.home-manager.nixosModules.home-manager
              else inputs.home-manager-unstable.nixosModules.home-manager
            )

            ./hosts/${cfg.hostname}/configuration.nix

            {
              nixpkgs = {
                inherit pkgs;
                config.allowUnfree = true;
                overlays = [ inputs.nur.overlays.default ];
              };
            }
          ];

          specialArgs = {
            inherit inputs cfg pkgs-stable pkgs-unstable;
          };
        };
  };
    # ------------------------------------------------------------
    # Split platforms
    # ------------------------------------------------------------
    nixosConfigs =
      builtins.filter (c: c.platform == "nixos") configurations;

    darwinConfigs =
      builtins.filter (c: c.platform == "darwin") configurations;

    # ------------------------------------------------------------
    # NixOS generator
    # ------------------------------------------------------------
    mkNixosConfig = cfg:
      let
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
            inputs.nix-flatpak.nixosModules.nix-flatpak

#            (if cfg.isStable
#              then inputs.home-manager.nixosModules.home-manager
#              else inputs.home-manager-unstable.nixosModules.home-manager
#            )

            ./hosts/${cfg.hostname}/configuration.nix

            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [ inputs.nur.overlays.default ];
              };
            }
          ];

          specialArgs = {
            inherit inputs cfg pkgs-stable pkgs-unstable;
          };
        };
      };

    # ------------------------------------------------------------
    # Darwin generator
    # ------------------------------------------------------------
    mkDarwinConfig = cfg: {
      name = cfg.hostname;
      value = inputs.nix-darwin.lib.darwinSystem {
        system = cfg.system;

        modules = [
          ./hosts/${cfg.hostname}/configuration.nix
          inputs.home-manager.darwinModules.home-manager
        ];

        specialArgs = {
          inherit inputs cfg self;
        };
      };
    };
     in {
       #Assemble all the system configurations, looping through the variable configurations
       #By calling the function mkConfig on each entry
       nixosConfigurations = builtins.listToAttrs (map mkSystem configurations);
       darwinConfigurations = builtins.listToAttrs (map mkSystem configurations);
     };
}
