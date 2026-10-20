{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    nextcloud-client = {
      enable = mkEnableOption "Enable the nextcloud-client module";
    };
  };

  config.environment.systemPackages = mkIf config.nextcloud-client.enable (
    with pkgs;
    [
      nextcloud-client
    ]
  );

}
