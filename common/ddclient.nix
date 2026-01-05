{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let
  cfg = config.flakecfg.ddclient;
in with lib; {
  services.ddclient = mkIf cfg.enable {
    enable = true;
    quiet = true;
    usev6 = "";
    protocol = "dyndns2";
    passwordFile = config.sops.secrets."ddclient-pass".path;
    server = "dynv6.com";
    username = "none";
    interval = "30min";
  };
}
