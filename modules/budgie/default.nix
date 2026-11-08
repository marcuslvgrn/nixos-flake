{ config, lib, ... }:
{
  config = lib.mkIf config.services.desktopManager.budgie.enable {
    desktopEnvironment.enable = true;
    services = {
      displayManager.gdm.enable = true;
    };
  };
}
