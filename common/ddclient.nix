{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
{
  services.ddclient = lib.mkIf config.services.ddclient.enable {
    quiet = true;
    usev6 = "";
    protocol = "dyndns2";
    passwordFile = config.sops.secrets."ddclient-pass".path;
    server = "dynv6.com";
    username = "none";
    interval = "30min";
  };
}
