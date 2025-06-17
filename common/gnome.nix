{ config, lib, pkgs, modulesPath, ... }:

{
  # Enable GNOME and GDM
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb.layout = "se";
  };
  
  # GNOME shell host connector
  services.gnome.gnome-browser-connector.enable = true;

  # Autologin a user
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lovgren";
  };
  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    gedit
    bitwarden
 ];
 
  # Exclude some packages
  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gedit # text editor
    gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ]);
  
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
