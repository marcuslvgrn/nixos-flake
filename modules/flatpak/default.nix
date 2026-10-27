{
  config,
  lib,
  inputs,
  ...
}:
let
  # Put applications wanted on every Flatpak-enabled host here.
  defaultPackages = [ ];
in
{

  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.flatpak.packages = lib.mkOption {
    type = lib.types.listOf (
      lib.types.oneOf [
        lib.types.str
        (lib.types.attrsOf lib.types.anything)
      ]
    );
    default = [ ];
    description = "Additional Flatpak applications to install on this host.";
    example = [
      "org.mozilla.firefox"
      {
        appId = "com.brave.Browser";
        origin = "flathub";
      }
    ];
  };

  config = lib.mkIf config.services.flatpak.enable {
    services.flatpak = {
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      update.auto.enable = false;
      uninstallUnmanaged = false;

      # Append shared defaults and host additions to any directly configured packages.
      packages = lib.mkAfter (defaultPackages ++ config.flatpak.packages);
    };
  };
}
