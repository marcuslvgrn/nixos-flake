{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let

in
{
  config = mkIf config.services.xserver.enable {

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      languagePacks = [
        "sv-SE"
        "en-US"
      ];
    };

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
        # For printers
        cups
        # Media streaming
        spotify # Streaming music
        yt-dlp # Download youtube videos
        # Network tools
        proton-vpn # VPN
        fragments # Torrents
        cifs-utils # Mount network drives
        # Bluetooth tools
        bluez
        bluez-tools
        # Devices
        libinput
        #Editors
        gimp # Image editor
        # Office programs
        libreoffice
        # Webcam
        cheese
      ])
      ++ [
      ];

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
    # Enable artcraft (a adobe suite replacement)
    programs.artcraft.enable = true;
    # Disable speechd (not needed)
    services.speechd.enable = false;

    programs.nm-applet.indicator = lib.mkForce true;

  };
}
