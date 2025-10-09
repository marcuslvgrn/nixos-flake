{ config, lib, pkgs, inputs, ... }:

{
  #Enable SSD trim
  services.fstrim.enable = lib.mkDefault true;
}
