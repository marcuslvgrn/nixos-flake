# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, cfg, pkgs, pkgs-stable, pkgs-unstable, self, ... }:

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
  
  # Enable alternative shell support in nix-darwin.
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      alias ll='ls -la'
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias rebuild='darwin-rebuild switch --flake ~/git/nixos-flake'
    '';
  };
    
  
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;
  
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
  users.users.lovgren.home = "/Users/lovgren";
  
}


