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

    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
#      fontconfig = {
#        enable = true;
#      };
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
          programs.nixvim = {
            colorschemes = {
              catppuccin.enable = false;
              catppuccin.settings.flavour = "mocha";
              catppuccin.settings.transparent_background = false;
            };
            opts = {
              background = "dark";
            };
            extraConfig = ''
    -- Enable truecolor
    vim.opt.termguicolors = true
    vim.opt.background = "dark"

    -- Force background everywhere
     vim.defer_fn(function()
      local hl = vim.api.nvim_set_hl
      hl(0, "Normal", { bg = "#1e1e2e" })
      hl(0, "NormalFloat", { bg = "#1e1e2e" })
      hl(0, "EndOfBuffer", { bg = "#1e1e2e" })
    end, 50)
            '';
          };
          
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
