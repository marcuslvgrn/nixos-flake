{
  description = "Marcus nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
  };

  outputs = inputs@{ nixpkgs, home-manager, sops-nix, ... }: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixosX360 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixosX360/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lovgren = import ./home-manager/lovgren.nix;
            home-manager.users.root = import ./home-manager/root.nix;
          }
        ];
      };
      nixosVMWare = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs home-manager; };
        modules = [
          ./hosts/nixosVMWare/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lovgren = import ./home-manager/lovgren.nix;
            home-manager.users.root = import ./home-manager/root.nix;
          }
        ];
      };
      nixosASUS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs home-manager; };
        modules = [
          ./hosts/nixosASUS/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lovgren = import ./home-manager/lovgren.nix;
            home-manager.users.root = import ./home-manager/root.nix;
          }
        ];
      };
    };
  };
}
