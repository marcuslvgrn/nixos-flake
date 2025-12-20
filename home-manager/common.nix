{ config, lib, cfg, usrcfg, pkgs, pkgs-unstable, inputs, ... }:

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
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
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
      ll = "ls -la";
      l = "ls -alh";
      ls = "ls --color=tty";
    };
    stateVersion = "25.05";
  };

  #  nixpkgs = {
  #    # You can add overlays here
  #    overlays = [
  #      # If you want to use overlays exported from other flakes:
  #      # neovim-nightly-overlay.overlays.default
  #
  #      # Or define it inline, for example:
  #      # (final: prev: {
  #      #   hi = final.hello.overrideAttrs (oldAttrs: {
  #      #     patches = [ ./change-hello-to-hi.patch ];
  #      #   });
  #      # })
  #    ];
  #    # Configure your nixpkgs instance
  #    config = {
  #      # Disable if you don't want unfree packages
  #      allowUnfree = true;
  #      # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #      allowUnfreePredicate = _: true;
  #    };
  #  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export LANG="en_US.UTF-8"
      export LC_MESSAGES="en_US.UTF-8"
    '';
  };

  #GIT
  programs.git = {
    enable = true;
    settings.user.email = "${usrcfg.email}";
    settings.user.name = "${usrcfg.gituser}";
  };

  programs.home-manager.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Nicely reload system units when changing configs
  #  systemd.user.startServices = "sd-switch";

}
