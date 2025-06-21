{ config, lib, pkgs, modulesPath, ... }:

{
  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    gedit
    bitwarden-desktop
 ];

  programs = {
    #FIREFOX
    firefox = {
      enable = true;
 #     enableGnomeExtensions = true;
      languagePacks = [ "sv-SE" ];
#      /* ---- EXTENSIONS ---- */
#      # Check about:support for extension/add-on ID strings.
#      # Valid strings for installation_mode are "allowed", "blocked",
#      # "force_installed" and "normal_installed".
#      ExtensionSettings = {
#        
#      };    
    };
  };
}
