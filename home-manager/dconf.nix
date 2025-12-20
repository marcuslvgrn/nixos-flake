# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
#dconf dump / > /home/lovgren/dconf.dump && dconf2nix -i /home/lovgren/dconf.dump -o /home/lovgren/dconf.nix
{ lib, cfg, ... }:
with lib.hm.gvariant;

{
  dconf.settings = lib.mkIf cfg.gnomeEnable {
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "se" ]) ];
      xkb-options = [];
    };

    "org/gnome/desktop/interface" = {
      accent-color = "blue";
      color-scheme = "default";
      cursor-theme = "Adwaita";
      document-font-name = "Adwaita Sans 12";
      font-name = "Adwaita Sans 11";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      monospace-font-name = "Adwaita Mono 11";
      scaling-factor = mkUint32 0;
      text-scaling-factor = 1.0;
      toolbar-icons-size = "large";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "appindicatorsupport@rgcjonas.gmail.com" "hidetopbar@mathieu.bidon.ca" "hibernate-status@dromi" ];
      favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "firefox.desktop" "emacs.desktop" "org.gnome.Settings.desktop" ];
    };
  };
}
