{ config, lib, pkgs, inputs, modulesPath, ... }:

{
  #Enable SSD trim
  services.fstrim.enable = lib.mkDefault true;
}
