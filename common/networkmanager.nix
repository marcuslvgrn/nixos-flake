{ pkgs, inputs, config, pkgs-unstable, ... }:

{
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # programs.nm-applet = true; # not needed in gnome

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  #Setup Wifi with networkmanager
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ config.sops.secrets."wifi.env".path ];
      profiles = {
        home-wifi = {
          connection = {
            id = "Marcus Wifi";
             type = "wifi";
          };
          wifi = {
            ssid = "$home_ssid";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$home_psk";
          };
        };
      };
    };
  };
}
