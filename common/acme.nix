{ config, pkgs, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "marcus.lovgren@proton.me";
    defaults.webroot = "/var/lib/acme/acme-challenge";
  };
  users = lib.mkIf config.services.nginx.enable {
    users.nginx.extraGroups = [ "acme" ];
  };
}
