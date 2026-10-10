{
  #  pkgs,
  #  inputs,
  hostCfg,
  ...
}:
{

  imports = [

  ];

  home = {
    stateVersion = hostCfg.stateVersion;
    sessionVariables = {
      LANG = "en_US.UTF-8";
      EDITOR = "emacs -nw";
    };
  };

}
