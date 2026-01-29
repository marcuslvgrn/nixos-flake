{ config, lib, ... }:

{
  imports = [
    ./disk-config.nix
    ../../common/configuration.nix
  ];
}

