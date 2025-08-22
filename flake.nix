{
  description = "Marcus nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, disko, nixos-facter-modules
    , sops-nix, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      #This is the hosts configuration function, takes the hostname as argument
      host-cfg = hostname:
        #Declare the configuration
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs = { inherit inputs home-manager hostname disko pkgs-unstable; };
          modules = [
            #load the host specific configuration
            (./. + "/hosts" + ("/" + hostname) + "/configuration.nix")
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              #These are arguments for home-manager
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lovgren = import ./home-manager/lovgren.nix;
              home-manager.users.root = import ./home-manager/root.nix;
              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };
            }
          ];
        };
    in {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        nixosDellXPS = host-cfg "nixosDellXPS";
        nixosX360 = host-cfg "nixosX360";
        nixosVMWareMinimal = host-cfg "nixosVMWareMinimal";
        nixosVMWareGnome = host-cfg "nixosVMWareGnome";
        nixosVBoxMinimal = host-cfg "nixosVBoxMinimal";
        nixosVBoxGnome = host-cfg "nixosVBoxGnome";
        nixosASUS = host-cfg "nixosASUS";
        nixosTranfor = host-cfg "nixosTranfor";
        nixosMinimal = host-cfg "nixosMinimal";
      };
    };
}
