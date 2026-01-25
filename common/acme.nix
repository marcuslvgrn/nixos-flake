{ config, pkgs, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "marcus.lovgren@proton.me";
    defaults.webroot = "/var/lib/acme/acme-challenge";
  };
  users.users.nginx.extraGroups = lib.mkIf config.services.nginx.enable [ "acme" ];
}
