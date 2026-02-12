{
#  config,
  lib,
  nixosConfig,
  pkgs-unstable,
  ...
}:

{
    programs.firefox = lib.mkIf nixosConfig.programs.firefox.enable {
      #Let home-manager manage firefox, but only when installed in nixos
      enable = true;

      languagePacks = [
        "sv-SE"
        "en-US"
      ];

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
          floccus
          proton-pass
        ];
        settings = {
          "intl.locale.requested" = "sv-SE,en-US";
          "browser.startup.page" = 3;
          "browser.sessionstore.resume_from_crash" = true;
          "extensions.install.requireBuiltInCerts" = false;
          "extensions.autoDisableScopes" = 0;
          "browser.translations.neverTranslateLanguages" = "en,en-US,en-GB";
          "signon.rememberSignons" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "extensions.pocket.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
        };
      };
    };


}
