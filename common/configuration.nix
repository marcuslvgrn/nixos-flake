{ config, lib, hostCfg, pkgs, pkgs-stable, pkgs-unstable, ... }:
let
  moduleCfg = config;
in with lib;
{
  imports = [
    ./acme.nix
    ./airsonic.nix
    ./cups.nix
    ./ddclient.nix
    ./desktopManager.nix
    ./flatpak.nix
    ./gnome.nix
    ./grub.nix
    ./iperf.nix
    ./kde.nix
    ./nextcloud.nix
    ./networkmanager.nix
    ./nginx.nix
    ./openssh.nix
    ./passbolt.nix
    ./technitium.nix
    ./users.nix
    ./samba.nix
    ./sops.nix
    ./vaultwarden.nix
    ./wakeOnLan.nix
    ./xfce.nix
    ../services/create-swapfile.nix
  ];

  options = {
    #Users
    userNames = mkOption {
      type = types.listOf types.str;
      default = [ "lovgren" ];
    };
    #Desktop
    programs = {

    };
  };

  config = {
    nix.gc = {
      automatic = true;
      persistent = true;
      dates = "20:00";
      options = "--delete-older-than 14d";
      #    delete_generations = "+5";
    };
    
    nix.extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';

    nix.settings.auto-optimise-store = true;
    
    # Enable the Flakes feature and the accompanying new nix command-line tool
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    # Set your time zone.
    time.timeZone = "Europe/Stockholm";
    
    # Select internationalisation properties.
    i18n = {
      defaultLocale = "sv_SE.UTF-8";
      extraLocales = [ "en_US.UTF-8/UTF-8" ];
    };
    console = {
      font = "Lat2-Terminus16";
      keyMap = "sv-latin1";
    };

    # Call commands and interactive bash start
    # Commands are separated by \n
    programs.bash.interactiveShellInit = ''
     neofetch
    '';
    
    # Use latest kernel if unstable, default is pkgs.linuxPackages
    # https://search.nixos.org/options?channel=25.11&show=boot.kernelPackages&query=boot.kernelpackages
    boot.kernelPackages = lib.mkIf (!hostCfg.isStable) pkgs.linuxPackages_latest;
    
    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages =
      (with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        efibootmgr
        neofetch
        gitFull
        #GPG
        age
        sops
        gnupg
        #      pinentry
        pinentry-curses
        #
        emacs
        nixfmt
        nixd
        traceroute
        dig
        btrfs-progs
        stow # handle dotfiles in home directory
        ssh-to-age #for sops-nix
        mkpasswd
        gptfdisk
        nix-tree #show nix disk usage
        gcc
        gnumake
        compsize
        pciutils
        usbutils
        iperf3 #measure network performance
        nurl #generate fetcher based on url
      ])
      ++
      (with pkgs-stable; [
        
      ])
      ++
      (with pkgs-unstable; [
        
      ]);
    
    services.emacs.defaultEditor = true;
    services.printing.enable = true;
    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      #    pinentryFlavor = "curses";
      enableSSHSupport = true;
    };
    
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    
    nixpkgs.hostPlatform = hostCfg.system;
    networking = {
      hostName = hostCfg.hostname;
      useDHCP = lib.mkDefault true;
      enableIPv6 = false;
    };

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
  };
}
