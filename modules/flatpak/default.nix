{
  config,
  lib,
  inputs,
  ...
}:
let
in
with lib;
{

  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = mkIf config.services.flatpak.enable {
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    update.auto.enable = false;
    uninstallUnmanaged = false;

    # Add here the flatpaks you want to install
    packages = [
      #{ appId = "com.brave.Browser"; origin = "flathub"; }
      #"com.obsproject.Studio"
      #"im.riot.Riot"
      #"com.brave.Browser"
    ];
  };
}
