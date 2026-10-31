{
  config,
  lib,
  hostSettings,
  pkgs,
  #  pkgs-stable,
  #  pkgs-unstable,
  ...
}:
let

in
with lib;
{
  imports = [
    ./users
  ];

  options = {
    # Options here are for homemanager to find them in nixosConfig
    userNames = mkOption {
      description = "Host specific user names";
      type = types.listOf types.str;
    };
    extraFirefoxExtensions = mkOption {
      type = types.listOf types.str;
      description = "Host specific firefox extensions";
    };
    extraFavoriteApps = mkOption {
      type = types.listOf types.str;
      description = "Host specific favorite apps (for dock)";
    };
    startFirefoxAtLogin = mkEnableOption "Enable starting firefox at login";
  };

  config = {
    # For when nixos-rebuild with --target-host
    #    nix.settings.require-sigs = false;
    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';
    };

    userNames = mkAfter [ "lovgren" ];

    # create-swapfile module is shared by all hosts (previously imported directly
    # here); enable it in the shared config so every host gets it.
    create-swapfile.enable = true;
    nix = {
      gc = {
        automatic = true;
        persistent = true;
        dates = "20:00";
        options = "--delete-older-than 14d";
        #    delete_generations = "+5";
      };

      extraOptions = ''
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      settings.auto-optimise-store = true; # optimize store on every build
      #optimise.automatic = true;
      #optimise.dates = [ "21:00" ]; # Optional; allows customizing optimisation schedule

      # Enable the Flakes feature and the accompanying new nix command-line tool
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

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
      earlySetup = true;
    };

    # Use latest kernel if unstable, default is pkgs.linuxPackages
    # https://search.nixos.org/options?channel=25.11&show=boot.kernelPackages&query=boot.kernelpackages
    boot.kernelPackages = lib.mkIf (
      hostSettings.defaultPkgChannel == "unstable"
    ) pkgs.linuxPackages_latest;

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = (
      with pkgs;
      [
        wget
        efibootmgr
        fastfetch
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
        ssh-to-age # for sops-nix
        mkpasswd
        gptfdisk
        nix-tree # show nix disk usage
        gcc
        gnumake
        compsize
        pciutils
        usbutils
        iperf3 # measure network performance
        nurl # generate fetcher based on url
        ripgrep
        ncdu
        e2fsprogs
        kiro-cli
      ]
    )
    #      ++
    #      (with pkgs-stable; [])
    #      ++
    #      (with pkgs-unstable; [])
    ;

    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      fontconfig = {
        enable = true;
      };
    };

    services = {
      openssh.enable = true;
      emacs.defaultEditor = true;
      pcscd.enable = true;
      timesyncd = {
        enable = true;
        servers = [ "ntp.lth.se" ];
      };
    };
    programs = {
      # Call commands and interactive bash start
      # Commands are separated by \n
      bash.interactiveShellInit = ''
        fastfetch
      '';

      gnupg.agent = {
        enable = true;
        #    pinentryFlavor = "curses";
        enableSSHSupport = true;
      };

    };

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    boot.initrd.availableKernelModules = lib.mkDefault [
      "ata_piix"
      "mptspi"
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "sd_mod"
      "sr_mod"
      "nvme"
    ];
    boot.initrd.kernelModules = lib.mkDefault [ ];
    boot.kernelModules = lib.mkDefault [ ];
    boot.extraModulePackages = lib.mkDefault [ ];
    boot.zfs.forceImportRoot = false;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    nixpkgs.hostPlatform = hostSettings.system;
    networking = {
      hostName = hostSettings.hostname;
      useDHCP = lib.mkDefault true;
      enableIPv6 = false;
      networkmanager.enable = true;
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
    # Set per-host in flake.nix overrides. Must match the NixOS version at first
    # install — never change it after that, even when upgrading NixOS.
    system.stateVersion = hostSettings.stateVersion;
  };
}
