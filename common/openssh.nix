{ inputs, config, lib, pkgs, ... }:

{
  #configure SSH
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "yes"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };
}
