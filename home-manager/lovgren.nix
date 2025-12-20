{ config, lib, cfg, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [

  ];

  programs.firefox = {
    enable = true;
    languagePacks = [ "sv-SE" "en-US" ];

    policies = {
      DisableFirefoxAccounts = true;
      DisableSync = true;
    };
    
    profiles.Marcus = {
      name = "Marcus";
      isDefault = true;
      search = {
        force = true;
        default = "ddg";
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
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

# Add stuff for your user as you see fit:
# programs.neovim.enable = true;
# home.packages = with pkgs; [ steam ];

# Nicely reload system units when changing configs
#  systemd.user.startServices = "sd-switch";
#
}
