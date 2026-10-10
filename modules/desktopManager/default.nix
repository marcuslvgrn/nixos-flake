{
  config,
  lib,
  pkgs,
  #  pkgs-stable,
  pkgs-unstable,
  ...
}:
with lib;
let

in
{
  config = mkIf config.services.xserver.enable {

    services = {
      xserver.xkb.layout = "se";
    };

    # Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages =
      (with pkgs; [
        # Browsers
        chromium
        microsoft-edge
        brave
        cups
        spotify
        bitwarden-desktop
        proton-vpn
        yt-dlp
        nextcloud-client
        bluez
        bluez-tools
        libinput
        gimp
        libreoffice
        cheese
        fragments
      ])
      #      ++ (with pkgs-stable; [])
      # Uncomment and populate either block to pin specific packages to stable or
      # unstable regardless of the host's isStable setting (see technitium for an example).
      ++ (with pkgs-unstable; [ libinput ]);

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
    # Enable teamviewer
    services.teamviewer.enable = true;
    # Enable artcraft (a adobe suite replacement)
    programs.artcraft.enable = true;
    # Disable speechd (not needed)
    services.speechd.enable = false;
  };
}
