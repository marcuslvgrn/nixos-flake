{
  config,
  lib,
  #  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:

{
  #  environment.systemPackages =
  #    (with pkgs; [])
  #    ++ (with pkgs-stable; [])
  #    ++ (with pkgs-unstable; [])
  #    ;

  #Host extensions (USB forwarding) - causes frequent rebuilds
  #virtualisation.virtualbox.host = lib.mkIf config.virtualisation.virtualbox.host.enable {
  #  enableExtensionPack = true;
  #};

  users.extraGroups.vboxusers = lib.mkIf config.virtualisation.virtualbox.host.enable {
    members = [ "lovgren" ];
  };

  #virtualbox guest
  #value = lib.mkIf config.virtualisation.virtualbox.guest.enable {
  #
  #};

}
