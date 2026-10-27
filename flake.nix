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
      # Discover every directory under hosts; each one must be a complete host.
      hostEntries = builtins.readDir ./hosts;
      hostFolders = builtins.filter (hostname: hostEntries.${hostname} == "directory") (
        builtins.attrNames hostEntries
      );

      # Load hostSettings.nix, validate required values, and add shared host fields.
      mkHostCfg =
        hostname:
        let
          hostDir = ./hosts + "/${hostname}";
          hostSettingsFile = hostDir + "/hostSettings.nix";
          nixosModulePath = hostDir + "/configuration.nix";
          checkedNixosModulePath =
            if builtins.pathExists nixosModulePath then
              nixosModulePath
            else
              builtins.throw "hosts/${hostname}/configuration.nix is missing";
          hostSettings =
            if builtins.pathExists hostSettingsFile then
              import hostSettingsFile
            else
              builtins.throw "hosts/${hostname}/hostSettings.nix is missing — create it with stateVersion and defaultPkgChannel";
          stateVersion =
            if hostSettings ? stateVersion then
              hostSettings.stateVersion
            else
              builtins.throw "hosts/${hostname}/hostSettings.nix must define stateVersion";
          # Takes a channel name, fallback value, and required flag; returns a
          # validated "stable" or "unstable" string, or throws a host-specific error.
          resolveChannel =
            name: fallback: required:
            let
              isSet = builtins.hasAttr name hostSettings;
              channel = if isSet then hostSettings.${name} else fallback;
            in
            if required && !isSet then
              builtins.throw "hosts/${hostname}/hostSettings.nix must define ${name} as \"stable\" or \"unstable\""
            # builtins.elem verifies the channel is one of the supported values.
            else if
              builtins.elem channel [
                "stable"
                "unstable"
              ]
            then
              channel
            else
              builtins.throw "hosts/${hostname}/hostSettings.nix ${name} must be \"stable\" or \"unstable\"";
          defaultPkgChannel = resolveChannel "defaultPkgChannel" null true;
          homeManagerChannel = resolveChannel "homeManagerChannel" defaultPkgChannel false;
          nixvimChannel = resolveChannel "nixvimChannel" defaultPkgChannel false;
        in
        hostSettings
        // {
          inherit
            hostname
            stateVersion
            defaultPkgChannel
            homeManagerChannel
            nixvimChannel
            ;
          system = "x86_64-linux";
          nixosModulePath = checkedNixosModulePath;
        };

      allHostCfgs = map mkHostCfg hostFolders;

      # Import a nixpkgs input with the host's shared system and package settings.
      mkPkgs =
        nixpkgs: hostSettings: overlays:
        import nixpkgs {
          system = hostSettings.system;
          config.allowUnfree = true;
          inherit overlays;
        };

      # Assemble one complete NixOS configuration from a validated host config.
      mkSystem =
        hostSettings:
        let
          overlays = [
            inputs.nur.overlays.default
            self.overlays.firefox
          ];
          # ------------------------------------------------------------
          # Define nixpkgs variants for stable and unstable
          # ------------------------------------------------------------
          pkgs-stable = mkPkgs inputs.nixpkgs hostSettings overlays;
          pkgs-unstable = mkPkgs inputs.nixpkgs-unstable hostSettings overlays;
          # This is the chosen nixpkg based on configuration
          useStable = hostSettings.defaultPkgChannel == "stable";
          pkgs = if useStable then pkgs-stable else pkgs-unstable;
          #For choosing the correct input libs based on configuration
          inputLib = if useStable then inputs.nixpkgs.lib else inputs.nixpkgs-unstable.lib;
          homeManagerInput =
            if hostSettings.homeManagerChannel == "stable" then
              inputs.home-manager
            else
              inputs.home-manager-unstable;
          homeManagerModule = homeManagerInput.nixosModules.home-manager;
        in
        {
          name = hostSettings.hostname;
          value = inputLib.nixosSystem {
            inherit pkgs;
            system = hostSettings.system;
            modules = [
              #load default.nix in the modules directory, will import all modules
              ./modules
              #load the correct home-manager module depending on configuration
              homeManagerModule
              #common configuration
              ./common/configuration.nix
              #host specific configuration
              hostSettings.nixosModulePath
              {
                #For printing commit messages in nixos-generations
                system.configurationRevision = if self ? dirtyRev then "${self.dirtyRev}-dirty" else self.rev;
              }
            ];
            specialArgs = {
              inherit hostSettings;
              inherit
                inputs
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
      # Assemble all host configurations as NixOS systems.
      nixosConfigurations = builtins.listToAttrs (map mkSystem allHostCfgs);
      # Expose pinned nixos-anywhere so install.sh can use it via `nix run .#nixos-anywhere`
      apps.x86_64-linux.nixos-anywhere = {
        type = "app";
        program = "${inputs.nixos-anywhere.packages.x86_64-linux.nixos-anywhere}/bin/nixos-anywhere";
      };
    };
}
