{ config, lib, ... }:
{
  config = lib.mkIf config.services.desktopManager.cosmic.enable {
    services.displayManager.gdm.enable = true;
  };
}
