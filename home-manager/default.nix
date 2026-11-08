{
  lib,
  userConfig,
  hostSettings,
  config,
  nixosConfig,
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
        gl = "git log";
        rebuild-switch = lib.mkDefault "nixos-rebuild switch --flake ~/git/nixos-flake --log-format bar-with-logs";
        rebuild-boot = lib.mkDefault "nixos-rebuild boot --flake ~/git/nixos-flake --log-format bar-with-logs";
        rebuild-build = lib.mkDefault "nixos-rebuild build --flake ~/git/nixos-flake --log-format bar-with-logs";
        sudo = "sudo ";
      };
      stateVersion = hostSettings.stateVersion;
    };

    programs.fastfetch = {
      enable = true;
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        export LANG="en_US.UTF-8"
        export LC_MESSAGES="en_US.UTF-8"
      ''
      # Start tmux if enabled
      + lib.optionalString config.programs.tmux.enable ''
        if [[ -z "$TMUX" && -n "$PS1" && -t 0 ]]; then
          exec tmux new-session -A -s main
        fi
      '';
    };

    programs.zsh = {
      enable = true;
      initContent = ''
        export LANG="en_US.UTF-8"
        export LC_MESSAGES="en_US.UTF-8"
      ''
      # Start tmux if enabled
      + lib.optionalString config.programs.tmux.enable ''
        if [[ -z "$TMUX" && -n "$PS1" && -t 0 ]]; then
          exec tmux new-session -A -s main
        fi
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
