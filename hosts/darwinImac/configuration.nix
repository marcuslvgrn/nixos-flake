{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  self,
  ...
}:
let
  userData = import ../../common/users/userData.nix;
  usersByName = userData.users;
  #TODO, use mkHomeUser
  userConfig = usersByName."lovgren";
  nixosConfig = config;
in
with lib;
{
  imports = [

  ];

  options = {
    programs.firefox.enable = mkEnableOption "Enable firefox";
  };

  config = {

    programs.firefox.enable = true;

    environment.systemPackages =
      (with pkgs; [
        vim
        emacs
        neofetch
        stow
        sops
        nixfmt
      ])
#      ++ (with pkgs-stable; [])
#      ++ (with pkgs-unstable; [])
      ;

    homebrew = {
      enable = true;
      taps = [ ];
      brews = [ "cowsay" "sleepwatcher" "blueutil" ];
      casks = [ ];
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
            ../../home-manager
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
        inherit usrcfg pkgs-stable pkgs-unstable nixosConfig userConfig inputs;
      };
    };
  };
}
