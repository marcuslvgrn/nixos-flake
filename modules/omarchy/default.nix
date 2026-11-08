{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.omarchy-nix.nixosModules.default ];

  config = lib.mkMerge [
    {
      # Home Manager applies sharedModules to each configured user. Keep this
      # unconditional so the user's omarchy option is declared on every host.
      home-manager.sharedModules = [ inputs.omarchy-nix.homeModules.default ];
    }
    (lib.mkIf config.omarchy.enable {
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      # Quickshell is pinned to Qt 6.11 while the system Qt is newer. Put its
      # matching image plugins first so it can decode Omarchy's WebP wallpapers.
      environment.sessionVariables.QT_PLUGIN_PATH = lib.mkForce (
        "${
          inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.qt6.qtimageformats
        }/lib/qt-6/plugins:${config.system.path}/lib/qt-6/plugins"
      );

      # IBus' generic desktop-file autostart launches its daemon outside the
      # compositor's Wayland input-method setup and raises a warning on Omarchy.
      # Omarchy does not use IBus as its Wayland input method.
      systemd.user.services."app-ibus\\x2ddaemon@autostart".enable = false;

      # Use the upstream Omarchy desktop shell, bar, shortcuts, and menu here.
      omarchy = {
        sddm.theme = false;
        theme = "tokyo-night";
        #exclude_packages = [
        #  "owe"
        #];
      };
      # Keep GNOME's GDM as the sole display manager; the Omarchy shell does not
      # depend on SDDM or its greeter theme.
      services.displayManager.sddm.enable = false;
      # GNOME and Omarchy provide different Nautilus extension paths. Follow
      # GNOME's store-backed path so its extensions remain discoverable.
      environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = lib.mkForce (
        "${config.system.path}/lib/nautilus/extensions-4"
      );
      environment.sessionVariables.OMARCHY_NIX_FLAKE = "/home/lovgren/git/nixos-flake";

      programs.tmux.enable = true;
    })
  ];
}
