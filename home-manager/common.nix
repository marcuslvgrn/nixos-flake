{ config, lib, cfg, usrcfg, pkgs, pkgs-stable, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./dconf.nix
  ];

  programs.firefox = {
    enable = true;
    languagePacks = [ "sv-SE" "en-US" ];

    policies = {
      DisableFirefoxAccounts = true;
      DisableSync = true;
    };
    
    profiles.default = {
      name = "default";
      isDefault = true;
      search = {
        force = true;
        default = "ddg";
      };
      extensions.packages = with pkgs-unstable.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        i-dont-care-about-cookies
        istilldontcareaboutcookies
        gnome-shell-integration
        duckduckgo-privacy-essentials
      ];
      settings = {
        "intl.locale.requested" = "sv-SE,en-US";
        "browser.startup.page" = 3;
        "browser.sessionstore.resume_from_crash" = true;
        "extensions.install.requireBuiltInCerts" = false;
        "extensions.autoDisableScopes" = 0;
        "browser.translations.neverTranslateLanguages" = "en,en-US,en-GB";
        "signon.rememberSignons" = false;
      };
    };
  };
  
  home = {
    username = usrcfg.username;
    homeDirectory = "/home/${usrcfg.username}";
    sessionVariables = {
      LANG = "sv_SE.UTF-8";
#      XDG_DATA_DIRS = lib.mkMerge [
#        (lib.mkDefault "/run/current-system/sw/share")
#        (lib.mkIf (config.home.username != null)
#          "/etc/profiles/per-user/${config.home.username}/share")
#      ];
#      GSETTINGS_SCHEMA_DIR = "/run/current-system/sw/share/glib-2.0/schemas";
    };
    shellAliases = {
      ll = "ls -lah";
      ls = "ls --color=tty";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gps = "git push";
      gpl = "git pull";
      gd = "git diff";
      rebuild = "nixos-rebuild switch --flake ~/git/nixos-flake";
      sudo = "sudo ";
    };
    stateVersion = "25.05";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export LANG="en_US.UTF-8"
      export LC_MESSAGES="en_US.UTF-8"
    '';
  };

  programs.git = {
    enable = true;
    settings.user.email = "${usrcfg.email}";
    settings.user.name = "${usrcfg.gituser}";
  };

  programs.home-manager.enable = true;

}
