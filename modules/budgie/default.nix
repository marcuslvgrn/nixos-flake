{ config, lib, ... }:
{
  config = lib.mkIf config.services.desktopManager.budgie.enable {
    services.displayManager.gdm.enable = true;
  };
}
