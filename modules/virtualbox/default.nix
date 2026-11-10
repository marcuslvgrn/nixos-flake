{
  config,
  lib,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:

{
  options.virtualbox.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "lovgren" ];
    description = "Users to add to the VirtualBox host group.";
  };

  config = {
    assertions = lib.mkIf config.virtualisation.virtualbox.host.enable [
      {
        assertion = lib.all (username: config.users.users ? ${username}) config.virtualbox.users;
        message = "Every virtualbox.users entry must name a local user configured on this host.";
      }
    ];

    #  environment.systemPackages =
    #    (with pkgs; [])
    #    ++ (with pkgs-stable; [])
    #    ++ (with pkgs-unstable; [])
    # Uncomment the block above to add packages, using either block to pin to stable
    # or unstable regardless of the host's defaultPkgChannel setting (see technitium for an example).
    #    ;

    #Host extensions (USB forwarding) - causes frequent rebuilds
    #virtualisation.virtualbox.host = lib.mkIf config.virtualisation.virtualbox.host.enable {
    #  enableExtensionPack = true;
    #};

    users.extraGroups.vboxusers = lib.mkIf config.virtualisation.virtualbox.host.enable {
      members = config.virtualbox.users;
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
  };
}
