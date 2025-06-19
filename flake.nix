{
  description = "Marcus nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixosX360 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixosX360/configuration.nix
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
        #        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixosVMWare/configuration.nix
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
