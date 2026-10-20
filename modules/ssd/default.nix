{
  config,
  lib,
#  pkgs,
#  inputs,
  ...
}:
with lib;
{
  options = {
    ssd.enable = mkEnableOption "enable SSD settings";
  };

  config = lib.mkIf config.ssd.enable {
    #Enable SSD trim
    services.fstrim.enable = true;
  };
}
