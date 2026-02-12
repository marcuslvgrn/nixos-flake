{
  #  config,
  lib,
  #  inputs,
  # nixosConfig,
  userConfig,
  #  pkgs,
  #  pkgs-stable,
  # pkgs-unstable,
  ...
}:

{
  imports = [
    ./modules
  ];

  options = {
    nixvimEnable = lib.mkEnableOption "Enable nixvim";
  };

  config = {

    nixvimEnable = true;

    home = {
      username = userConfig.username;
      homeDirectory = lib.mkDefault "/home/${userConfig.username}";
      sessionVariables = {
        LANG = "sv_SE.UTF-8";
        #      XDG_DATA_DIRS = lib.mkMerge [
        #        (lib.mkDefault "/run/current-system/sw/share")
        #        (lib.mkIf (config.home.username != null)
        #          "/etc/profiles/per-user/${config.home.username}/share")
        #      ];
        #      GSETTINGS_SCHEMA_DIR = "/run/current-system/sw/share/glib-2.0/schemas";
      };
      shellAliases = {
        ll = "ls -lah";
        ls = "ls --color=tty";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gps = "git push";
        gpl = "git pull";
        gd = "git diff";
        rebuild = lib.mkDefault "nixos-rebuild switch --flake ~/git/nixos-flake";
        sudo = "sudo ";
      };
      stateVersion = "25.05";
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        export LANG="en_US.UTF-8"
        export LC_MESSAGES="en_US.UTF-8"
      '';
    };

    programs.zsh = {
      enable = true;
      initContent = ''
        export LANG="en_US.UTF-8"
        export LC_MESSAGES="en_US.UTF-8"
      '';
    };

    programs.git = {
      enable = true;
      settings.user.email = "${userConfig.email}";
      settings.user.name = "${userConfig.gituser}";
    };

    programs.home-manager.enable = true;
  };
}
