{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
with lib; {
  
  imports = [ ./flatpak.nix ];
  config = mkIf config.flakecfg.desktop.enable {

    services = {
      xserver.xkb.layout = "se";
    };

    # Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = (with pkgs; [
      spotify
      bitwarden-desktop
      protonvpn-gui
      chromium
      brave
      yt-dlp
      nextcloud-client
      bluez
      bluez-tools
      usbutils
      pciutils
      libinput
      gimp
      libreoffice
    ]) ++ (with pkgs-stable;
      [

      ]) ++ (with pkgs-unstable; [ libinput ]);

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
    services.teamviewer.enable = true;
    services.printing.enable = true;
  };
}
