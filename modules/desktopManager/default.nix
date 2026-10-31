{
  config,
  lib,
  pkgs,
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
        proton-vpn
        yt-dlp
        bluez
        bluez-tools
        libinput
        gimp
        libreoffice
        cheese
        fragments
        kiro
      ])
      # The stable channel's ChatGPT package is Darwin-only; unstable supports Linux.
      ++ [ pkgs-unstable.chatgpt ];

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
    # Enable artcraft (a adobe suite replacement)
    programs.artcraft.enable = true;
    # Disable speechd (not needed)
    services.speechd.enable = false;
  };
}
