{
  description = "Marcus nix config";

  inputs = {
    #Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-unstable-pkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    #Gather system information — planned replacement for hand-edited hardware-configuration.nix
    #Use nixos-facter to scan hardware at install time and generate a facter.json per host
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    #Nix user repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-unstable = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    artcraft.url = "github:ipeglin/artcraft-nix";
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      # Auto-detect host folders
      hostFolders = builtins.attrNames (builtins.readDir ./hosts);

      # Build a hostCfg attrset for each host by reading its hosts/<name>/hostCfg.nix.
      # Defaults are applied first, then merged with the host-specific file.
      #
      # stateVersion MUST be set in each hostCfg.nix — it must reflect the NixOS
      # version at first install and should never change after that. Only update
      # it when reinstalling a system or adding a new host. Omitting it is a
      # hard error to prevent silently inheriting a wrong value in the future.
      mkHostCfg =
        hostname:
        let
          system = "x86_64-linux";
          hostCfgFile = ./hosts/${hostname}/hostCfg.nix;
          # Hard error if hostCfg.nix is missing entirely
          hostOverrides =
            if builtins.pathExists hostCfgFile then
              import hostCfgFile
            else
              builtins.throw "hosts/${hostname}/hostCfg.nix is missing — create it with at least { stateVersion = \"<version>\"; }";
          # Hard error if stateVersion is not set
          checkedOverrides =
            if hostOverrides ? stateVersion then
              hostOverrides
            else
              builtins.throw "hosts/${hostname}/hostCfg.nix must define stateVersion";
        in
        # Defaults, overridden by the host-specific file
        {
          inherit hostname system;
          isStable = true;
        }
        // checkedOverrides;

      allHostCfgs = map mkHostCfg hostFolders;

      mkSystem =
        hostCfg:
        let
          allowUnfree = true;

          #nixpkgsConfig = {
          #  inherit allowUnfree;
          #};

          overlays = [
            inputs.nur.overlays.default
            self.overlays.firefox
            #            self.overlays.technitium
            #(self.overlays.php {
            #  inherit (inputs) nixpkgs-unstable-pkgs;
            #  config = nixpkgsConfig;
            #  system = hostCfg.system;
            #})
          ];
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
          inputLib = if hostCfg.isStable then inputs.nixpkgs.lib else inputs.nixpkgs-unstable.lib;
          homeManagerModule =
            (if hostCfg.isStable then inputs.home-manager else inputs.home-manager-unstable)
            .nixosModules.home-manager;
        in
        {
          name = hostCfg.hostname;
          value = inputLib.nixosSystem {
            inherit pkgs;
            system = hostCfg.system;
            modules = [
              #load default.nix in the modules directory, will import all modules
              ./modules
              #load the correct home-manager module depending on configuration
              homeManagerModule
              #common configuration
              ./common/configuration.nix
              #host specific configuration
              ./hosts/${hostCfg.hostname}/configuration.nix
              {
                #For printing commit messages in nixos-generations
                system.configurationRevision = if self ? dirtyRev then "${self.dirtyRev}-dirty" else self.rev;
              }
            ];
            specialArgs = {
              inherit
                inputs
                hostCfg
                pkgs-stable
                pkgs-unstable
                inputLib
                ;
            };
          };
        };
    in
    {
      overlays.firefox = import ./overlays/firefox.nix;
      overlays.technitium = import ./overlays/technitium-overlay.nix;
      #overlays.php = import ./overlays/php-overlay.nix;
      # Assemble all host configurations as NixOS systems.
      nixosConfigurations = builtins.listToAttrs (map mkSystem allHostCfgs);
      # Expose pinned nixos-anywhere so install.sh can use it via `nix run .#nixos-anywhere`
      apps.x86_64-linux.nixos-anywhere = {
        type = "app";
        program = "${inputs.nixos-anywhere.packages.x86_64-linux.nixos-anywhere}/bin/nixos-anywhere";
      };
    };
}
