{ config, lib, ... }:
{
  config = lib.mkIf config.services.xserver.desktopManager.cinnamon.enable {
    services.displayManager.gdm.enable = true;
  };
}
