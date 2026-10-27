{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.openssh.enable {
    services.openssh.settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false; # disable password login
      KbdInteractiveAuthentication = false; # disable PAM-based password prompts
    };
    services.openssh.openFirewall = true;
  };
}
