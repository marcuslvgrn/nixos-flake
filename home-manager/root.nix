{ pkgs, inputs, ... }:
{

  imports = [

  ];
  
  #GIT
  programs.git = {
    enable = true;
    userEmail = "marcuslvgrn@gmail.com";
    userName = "marcuslvgrn";
  };
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      l = "ls -alh";
      ls = "ls --color=tty";
    };
  };

  programs.home-manager.enable = true;

  home = {
    stateVersion = "25.05";
    sessionVariables = { LANG = "sv_SE.UTF-8"; EDITOR = "emacs -nw"; };
  };
}

