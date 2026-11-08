{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.desktopEnvironment.enable = lib.mkEnableOption "shared desktop environment support";

  config = lib.mkIf config.desktopEnvironment.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      languagePacks = [
        "sv-SE"
        "en-US"
      ];
    };

    services.xserver.xkb.layout = "se";

    # Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Common graphical applications and utilities.
    environment.systemPackages = with pkgs; [
      # Browsers
      chromium
      microsoft-edge
      #brave
      # For printers
      cups
      # Media streaming
      spotify # Streaming music
      yt-dlp # Download YouTube videos
      # Network tools
      proton-vpn # VPN
      fragments # Torrents
      cifs-utils # Mount network drives
      # Bluetooth tools
      bluez
      bluez-tools
      # Devices
      libinput
      # Editors
      gimp # Image editor
      # Office programs
      libreoffice
      # Webcam
      cheese
    ];

    services.libinput.enable = true;
    programs.artcraft.enable = true;
    services.speechd.enable = false;
    programs.nm-applet.indicator = lib.mkForce true;
  };
}
