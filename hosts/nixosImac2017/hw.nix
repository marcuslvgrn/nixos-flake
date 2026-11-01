{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Match the priority used by Nixpkgs' kernel variants (for example zen).
  mkKernelOverride = lib.mkOverride 90;

  imac5kPatchSource = pkgs.fetchFromGitHub {
    owner = "armin-haghi";
    repo = "imac-5k-display";
    rev = "3c7f7d57dc21b9a43997357c1e0690fa39acbd3c";
    hash = "sha256-gloKTw8oWzVBWCyuFKX4DrsPGfNgCnURfEB4C+g+cKU=";
  };

  imac5kKernel = pkgs.callPackage "${pkgs.path}/pkgs/os-specific/linux/kernel/mainline.nix" {
    # Use the Nixpkgs kernel builder, but supply the pinned 7.0.1 source. The
    # branch value only selects metadata in mainline.nix; argsOverride replaces
    # the source and version because Nixpkgs has removed the EOL linux_7_0 attr.
    branch = "7.3";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ]
    ++
      map
        (patch: {
          name = "imac-5k-${patch}";
          patch = "${imac5kPatchSource}/patches/${patch}.patch";
        })
        [
          "0001-apple-5k-dual-tile-core"
          "0002-apple-5k-panel-ids"
          "0003-apple-5k-root-latch-repulse"
          "0004-apple-5k-peer-wiring-evidence"
          "0005-apple-5k-backlight-connector"
          "0006-imac-5k-acpi-backlight"
        ];
    argsOverride = {
      src = pkgs.fetchurl {
        url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.1.tar.xz";
        hash = "sha256-ssk1o20kmA4R5ZvtPKVY6m1nYZ7ABl+qM1zcC2TYh78=";
      };
      version = "7.0.1";
      modDirVersion = "7.0.1";
      extraMeta.branch = "7.0";
      # Nixpkgs' common kernel config is newer than Linux 7.0.1 and contains
      # symbols that this older source does not know about.
      ignoreConfigErrors = true;
      structuredExtraConfig = with lib.kernel; {
        RUST = mkKernelOverride no;
      };
    };
  };

  imac5kKernelPackages = pkgs.linuxPackagesFor imac5kKernel;
in

{
  imports = [
    #./thunderbolt-suspend.nix
  ];

  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  environment.systemPackages = (
    with pkgs;
    [
      #    fprintd
      #    libva-utils
      #    vdpauinfo
      #    intel-gpu-tools
      #    cifs-utils
    ]
  )
  #      ++ (with pkgs-stable; [])
  #      ++ (with pkgs-unstable; [])
  # Uncomment either block above to pin specific packages to stable or unstable
  # regardless of the host's defaultPkgChannel setting (see technitium for an example).
  ;

  boot = {
    kernelParams = [
      "video=eDP-1:2560x1440@60e"
      "mem_sleep_default=s2idle"
      "resume_offset=12002560"
      #    "kvm.enable_virt_at_load=0"
    ];
  };
  boot.extraModulePackages = [
    (pkgs.callPackage ./cs8409-module.nix {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = [ "snd_hda_codec_cs8409" ];

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
    }
  ];

  #  fileSystems."/mnt/nixosTranfor" = {
  #    device = "//nixosTranfor/data";
  #    fsType = "cifs";
  #    options = [
  #      "user,users"
  #      "uid=1000,gid=100"
  #      "file_mode=0664,dir_mode=0775"
  #    ];
  #  };

  boot.resumeDevice = "/dev/disk/by-partlabel/NIXOSROOT";

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:1"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "compress=none"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/NIXOSROOT";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:1"
    ];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/5F66-17ED";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  systemd.sleep.settings.Sleep.MemorySleepMode = "s2idle";

  # Temporary native-5K experiment. Keep the normal kernel in the previous
  # boot generation so the machine can be reverted from the boot menu.
  boot.kernelPackages = lib.mkForce imac5kKernelPackages;
  # Give time to select the previous working generation in GRUB if needed.
  boot.loader.timeout = lib.mkForce 5;

  ssd.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = (
      with pkgs;
      [
        #      intel-media-driver
        #      intel-vaapi-driver
        #      libvdpau-va-gl
        #      vpl-gpu-rt
      ]
    )
    #        ++ (with pkgs-stable; [])
    #        ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
    ;
  };
  #environment.sessionVariables = {
  #  LIBVA_DRIVER_NAME = "iHD";
  #  VDPAU_DRIVER = "va_gl";
  #};

}
