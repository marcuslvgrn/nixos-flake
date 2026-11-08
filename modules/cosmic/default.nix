{ config, lib, ... }:
{
  config = lib.mkIf config.services.desktopManager.cosmic.enable {
    desktopEnvironment.enable = true;
    services = {
      displayManager.gdm.enable = true;
    };
  };
}
