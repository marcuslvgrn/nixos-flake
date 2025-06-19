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
          ./common/gnome.nix
          ./common/grub.nix
          ./common/networkmanager.nix
          ./common/openssh.nix
          ./common/soap-nix.nix
          ./common/users.nix
          ./hosts/nixosX360/configuration.nix
          
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lovgren = import ./home-manager/lovgren.nix;
            home-manager.users.root    = import ./home-manager/root.nix;
          }
        ];
      };
      nixosVMWare = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
#        specialArgs = {inherit inputs outputs;};
        modules = [
          ./common/gnome.nix
          ./common/grub.nix
          ./common/networkmanager.nix
          ./common/openssh.nix
          ./common/soap-nix.nix
          ./common/users.nix
          ./common/vmware.nix
          ./hosts/nixosVMWare/configuration.nix
          
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lovgren = import ./home-manager/lovgren.nix;
            home-manager.users.root    = import ./home-manager/root.nix;
          }
        ];
      };
    };
  };
}
