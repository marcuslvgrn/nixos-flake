{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    bitwarden-desktop = {
      enable = mkEnableOption "Enable the nextcloud-client module";
    };
  };

  config.environment.systemPackages = mkIf config.bitwarden-desktop.enable (
    with pkgs;
    [
      bitwarden-desktop
    ]
  );

}
