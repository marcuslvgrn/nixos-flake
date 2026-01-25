{ config, lib, ... }:
let
  cfg = config.programs.flatpak;
  serviceCfg = config.services.flatpak;
in with lib; {

  services.flatpak = mkIf serviceCfg.enable {
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
