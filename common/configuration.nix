{ config, lib, pkgs, inputs, modulesPath, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "Mon..Sun *-*-* 12:00";
    options = "--delete-older-than 10d";
#    delete_generations = "+5";
  };

  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "sv_SE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Configure keymap in X11
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Call commands and interactive bash start
  # Commands are separated by \n
  programs.bash.interactiveShellInit = ''
    LANG=en_US.UTF-8
     neofetch
  '';

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    efibootmgr
    neofetch
    gitFull
    #GPG
    age
    sops
    gnupg
    pinentry
    pinentry-curses
    #
    emacs
    nixfmt-classic
    nixd
    traceroute
    dig
    btrfs-progs
    stow # handle dotfiles in home directory
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    #    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
