{
  description = "Marcus nix config";

  inputs = {
    #Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin-unstable = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
      mkHostCfg = hostname:
        let
          platform = if builtins.match "darwin.*" hostname != null then "darwin" else "nixos";
          system = if platform == "nixos" then "x86_64-linux" else "x86_64-darwin";
          hostCfgFile = ./hosts/${hostname}/hostCfg.nix;
          # Hard error if hostCfg.nix is missing entirely
          hostOverrides =
            if builtins.pathExists hostCfgFile
            then import hostCfgFile
            else builtins.throw "hosts/${hostname}/hostCfg.nix is missing — create it with at least { stateVersion = \"<version>\"; }";
          # Hard error if stateVersion is not set
          checkedOverrides =
            if hostOverrides ? stateVersion
            then hostOverrides
            else builtins.throw "hosts/${hostname}/hostCfg.nix must define stateVersion";
        in
        # Defaults, overridden by the host-specific file
        {
          inherit hostname platform system;
          isStable = true;
        } // checkedOverrides;

      allHostCfgs = map mkHostCfg hostFolders;

      # Split by platform
      nixosHosts = builtins.filter (c: c.platform == "nixos") allHostCfgs;
      darwinHosts = builtins.filter (c: c.platform == "darwin") allHostCfgs;

      mkSystem =
        hostCfg:
        let
          overlays = [
            inputs.nur.overlays.default
            self.overlays.firefox
            #            self.overlays.technitium
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
            else if hostCfg.platform == "nixos" then
              inputs.nixpkgs-unstable.lib
            else
              inputs.nix-darwin-unstable.lib;
          #Choose the right home manager module
          homeManagerModule =
            #this returns the correct darwinModules or nixosModules from inputs.home-manager,
            #like inputs.home-manager.nixosModules.home-manager, also for stable or unstable
            if hostCfg.isStable then
              (builtins.getAttr (hostCfg.platform + "Modules") inputs.home-manager).home-manager
            else
              (builtins.getAttr (hostCfg.platform + "Modules") inputs.home-manager-unstable).home-manager;
        in
        {
          name = hostCfg.hostname;
          value =
            # Darwin host
            if hostCfg.platform == "darwin" then
              inputLib.darwinSystem {
                system = hostCfg.system;
                modules = [
                  #load the correct home-manager module depending on configuration
                  homeManagerModule
                  #host specific configuration
                  ./hosts/${hostCfg.hostname}/configuration.nix
                ];
                specialArgs = {
                  inherit
                    inputs
                    self
                    hostCfg
                    pkgs
                    pkgs-stable
                    pkgs-unstable
                    ;
                };
              }
            else
              # NixOS host
              inputLib.nixosSystem {
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
      #Assemble all the system configurations, looping through the variable configurations
      #by calling the function mkSystem on each entry. Separate nixos and darwin
      nixosConfigurations = builtins.listToAttrs (map mkSystem nixosHosts);
      darwinConfigurations = builtins.listToAttrs (map mkSystem darwinHosts);
      # Expose pinned nixos-anywhere so install.sh can use it via `nix run .#nixos-anywhere`
      apps.x86_64-linux.nixos-anywhere = {
        type = "app";
        program = "${inputs.nixos-anywhere.packages.x86_64-linux.nixos-anywhere}/bin/nixos-anywhere";
      };
    };
}
