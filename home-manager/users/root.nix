{
  #  pkgs,
  #  inputs,
  hostSettings,
  ...
}:
{

  imports = [

  ];

  home = {
    stateVersion = hostSettings.stateVersion;
    sessionVariables = {
      LANG = "en_US.UTF-8";
      EDITOR = "emacs -nw";
    };
  };

}
