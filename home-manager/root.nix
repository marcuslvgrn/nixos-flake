{ pkgs, ... }: {
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
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
            
