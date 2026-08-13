{
  config,
  lib,
  pkgs,
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

  # VirtualBox crashes when opening the GTK file chooser if GSettings
  # cannot find the GTK schemas.
  environment.extraInit = lib.mkIf config.virtualisation.virtualbox.host.enable ''
    export GSETTINGS_SCHEMA_DIR="${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas"
  '';

  #virtualbox guest
  #value = lib.mkIf config.virtualisation.virtualbox.guest.enable {
  #
  #};

}
