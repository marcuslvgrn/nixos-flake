# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ nixpkgs, config, lib, pkgs, ... }:

{

  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # TODO: Set your username
  home = {
    username = "lovgren";
    homeDirectory = "/home/lovgren";
    sessionVariables = { LANG = "sv_SE.UTF-8"; EDITOR = "emacs -nw"; SUDO_EDITOR = "emacs -nw"; };
    shellAliases = {
      ll = "ls -la";
      l = "ls -alh";
      ls = "ls --color=tty";
    };
    stateVersion = "25.05";
  };

  #  nixpkgs = {
  #    # You can add overlays here
  #    overlays = [
  #      # If you want to use overlays exported from other flakes:
  #      # neovim-nightly-overlay.overlays.default
  #
  #      # Or define it inline, for example:
  #      # (final: prev: {
  #      #   hi = final.hello.overrideAttrs (oldAttrs: {
  #      #     patches = [ ./change-hello-to-hi.patch ];
  #      #   });
  #      # })
  #    ];
  #    # Configure your nixpkgs instance
  #    config = {
  #      # Disable if you don't want unfree packages
  #      allowUnfree = true;
  #      # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #      allowUnfreePredicate = _: true;
  #    };
  #  };

  programs.bash = { enable = true; };

  #GIT
  programs.git = {
    enable = true;
    userEmail = "marcuslvgrn@gmail.com";
    userName = "marcuslvgrn";
  };

  #  home-manager.users.lovgren = { pkgs, ... }: {
  #    home.username = "lovgren";
  #    home.homeDirectory = "/home/lovgren";

  programs.home-manager.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  #  programs.home-manager.enable = true;
  #  programs.git.enable = true;

  # Nicely reload system units when changing configs
  #  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  #  home.stateVersion = "25.05";
}
