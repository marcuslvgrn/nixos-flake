{ pkgs, inputs, ... }:
{

  imports = [

  ];
  
  home = {
    stateVersion = "25.05";
    sessionVariables = { LANG = "en_US.UTF-8"; EDITOR = "emacs -nw"; };
  };

}

