{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages =
    (with pkgs-stable; [
    ])
    ++
    (with pkgs-unstable; [
      spotify
      bitwarden-desktop
      protonvpn-gui
      chromium
      yt-dlp
      nextcloud-client
      bluez
      bluez-tools
      usbutils
      pciutils
      libinput
    ]);

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.teamviewer.enable = true;
  
  programs = {
    #FIREFOX
    firefox = {
      enable = true;
      languagePacks = [ "sv-SE" ];
      #      /* ---- EXTENSIONS ---- */
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
#      policies = {
#        DisableTelemetry = true;
##        DisableFirefoxStudies = true;
#        EnableTrackingProtection = {
#          Value= true;
#          Locked = true;
#          Cryptomining = true;
#          Fingerprinting = true;
#        };
#        ExtensionSettings = {
#          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
#          # Adblock plus
#          "{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/adblock-plus/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          # Bitwarden
#          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden_password_manager/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          #DuckDuckGo privacy essentials
#          "jid1-ZAdIEUB7XOzOJw@jetpack" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-privacy-essentials/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          #GNOME shell-integration
#          "chrome-gnome-shell@gnome.org" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          #I don't care about cookies
#          "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          #SponsorBlock for Youtube
#          "sponsorBlocker@ajay.app" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
#            installation_mode = "force_installed";
#          };
#          #youtube ad auto-skipper
#          "{bd6b8f4a-b0c3-4d61-a0f8-5539d3df3959}" = {
#            install_url = "https://addons.mozilla.org/firefox/downloads/latest/yt-auto-skip/latest.xpi";
#            installation_mode = "force_installed";
#          };
#        };
        /* ---- PREFERENCES ---- */
        # Set preferences shared by all profiles.
#        Preferences = { 
#          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
#          "extensions.pocket.enabled" = lock-false;
#          "extensions.screenshots.disabled" = lock-true;
#          add global preferences here...
#        };
        /* ---- PROFILES ---- */
        # Switch profiles via about:profiles page.
        # For options that are available in Home-Manager see
        # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.profiles
        #profiles ={
          #default = {           # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
            #id = 0;               # 0 is the default profile; see also option "isDefault"
            #inherit extensions;
            #            name = "profile_0";   # name as listed in about:profiles
            #            isDefault = true;     # can be omitted; true if profile ID is 0
            #            settings = {          # specify profile-specific preferences here; check about:config for options
            #              "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            #              "browser.startup.homepage" = "https://nixos.org";
            #              "browser.newtabpage.pinned" = [{
            #                title = "NixOS";
            #                url = "https://nixos.org";
            #              }];
            #              # add preferences for profile_0 here...
            #            };
        #  };
          #          # add profiles here...
        #};
    #};    
    };
  };
}
