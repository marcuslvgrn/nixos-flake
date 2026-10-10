{
  #  config,
  #  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
{
  #load the module
  imports = [
    inputs.artcraft.nixosModules.default
  ];
}
