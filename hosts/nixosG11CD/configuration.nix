# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hw.nix
  ];

  programs.wakezilla.client = {
    enable = true;
  };

  services.desktopManager.gnome.enable = true;
  deskflow.enable = true;
  ssd.enable = true;
  services.easyswitch = {
    enable = false;
    user = "lovgren";
  };

  startFirefoxAtLogin = true;
  shutdownApp.enable = true;

  #environment.systemPackages = (
  #  with pkgs;
  #  [
  #    #])
  #    # Populate either block to pin specific packages to stable or unstable
  #    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
  #    #++ (with pkgs-stable; [
  #    #
  #    #])
  #    #++ (with pkgs-unstable; [
  #    #
  #  ]
  #);

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };

  environment.etc."xdg/autostart/deskflow.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Deskflow
    Exec=${lib.getExe pkgs.deskflow}
    Terminal=false
    OnlyShowIn=GNOME;
    X-GNOME-Autostart-enabled=true
  '';

}
