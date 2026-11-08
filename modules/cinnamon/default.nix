{ config, lib, ... }:
{
  config = lib.mkIf config.services.xserver.desktopManager.cinnamon.enable {
    desktopEnvironment.enable = true;
    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
    };
  };
}
