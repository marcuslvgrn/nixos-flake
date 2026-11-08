# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  #  hostSettings,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./hw.nix
  ];

  # Desktop managers
  services.desktopManager.gnome.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.desktopManager.budgie.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  omarchy = {
    enable = true;
    plymouth.enable = false;
  };

  ai-tools.cli.enable = true;
  ai-tools.gui.enable = true;

  # Enable teamviewer
  # services.teamviewer.enable = true;

  # Nextcloud client
  nextcloud-client.enable = true;
  # Bitwarden desktop
  bitwarden-desktop.enable = true;

  # Enable virtualbox
  virtualisation.virtualbox.host.enable = true;
  # Enable software KVM
  deskflow.enable = true;
  # ???
  services.orca.enable = mkForce false;
  # Autologin a user
  services.displayManager = {
    defaultSession = "gnome";
    autoLogin.enable = false;
    autoLogin.user = "lovgren";
  };

  # Install host specific firefox extensions
  extraFirefoxExtensions = [
    # To force h264 in youtube
    "enhanced-h264ify"
  ];

  #environment.systemPackages = (
  #  with pkgs;
  #  [
  #  ]
  #)
  #      ++ (with pkgs-stable; [])
  #      ++ (with pkgs-unstable; [])
  # Uncomment either block above to pin specific packages to stable or unstable
  # regardless of the host's defaultPkgChannel setting (see technitium for an example).
  #;

  # resolve environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR conflict between gnome and budgie
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce (
    let
      cfg = config.services.desktopManager.gnome;

      nixos-background-light = pkgs.nixos-artwork.wallpapers.simple-blue;
      nixos-background-dark = pkgs.nixos-artwork.wallpapers.simple-dark-gray;

      flashbackEnabled = cfg.flashback.enableMetacity || lib.length cfg.flashback.customSessions > 0;

      nixos-gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
        inherit (cfg)
          extraGSettingsOverrides
          extraGSettingsOverridePackages
          favoriteAppsOverride
          ;
        inherit
          flashbackEnabled
          nixos-background-dark
          nixos-background-light
          ;
      };
    in
    "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
  );

  #Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind = {
    settings.Login.HandleLidSwitch = "hibernate";
    settings.Login.HandlePowerKey = "ignore";
    settings.Login.HandlePowerKeyLongPress = "poweroff";
  };

}
