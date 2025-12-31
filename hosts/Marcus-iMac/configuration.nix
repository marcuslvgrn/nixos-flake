{ inputs, config, lib, cfg, pkgs, pkgs-stable, pkgs-unstable, self, ... }:

let 
  userData = import ../../common/userData.nix;
  usrcfg = builtins.elemAt userData.users 0;
in
{
  imports = [
#    ../../hosts/nixosMinimal/configuration.nix
#    ../../common/gnome.nix
#    ../../common/ssd.nix
#    ./hardware-configuration.nix
#    ./disk-config.nix
  ];


  environment.systemPackages =
    (with pkgs; [ 
      vim
      emacs
      neofetch
      stow
      sops
      nixfmt
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);
  
  homebrew = {
    enable = true;
    taps = [];
    brews = [ "cowsay" ];
    casks = [];
  };
  
  system.primaryUser = "lovgren";
  
  nix.settings.cores = 4;
  
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;
  
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
  users.users.lovgren.home = "/Users/lovgren";
  
  home-manager = {
    users = {
      lovgren = {
        imports = [
          ../../home-manager/common.nix
        ];
        home = {
          homeDirectory = "/Users/lovgren";
          shellAliases = {
            rebuild = "darwin-rebuild switch --flake ~/git/nixos-flake";
          };
        };
      };
    };
    extraSpecialArgs = {
      inherit usrcfg pkgs-stable pkgs-unstable;
    };
  };
    
  }


