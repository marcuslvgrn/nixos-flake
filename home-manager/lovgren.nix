{ config, lib, cfg, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [

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

  programs.home-manager.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Nicely reload system units when changing configs
  #  systemd.user.startServices = "sd-switch";

}
