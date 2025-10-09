{ config, lib, pkgs, ... }:

{
  #configure SSH
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };
}
