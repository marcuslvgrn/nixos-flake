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
    ssdEnable = mkEnableOption "enable SSD settings";
  };

  config = lib.mkIf config.ssdEnable {
    #Enable SSD trim
    services.fstrim.enable = true;
  };
}
