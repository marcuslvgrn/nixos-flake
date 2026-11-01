{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Match the priority used by Nixpkgs' kernel variants (for example zen).
  mkKernelOverride = lib.mkOverride 90;

  imac5kKernel = pkgs.callPackage "${pkgs.path}/pkgs/os-specific/linux/kernel/mainline.nix" {
    # Linux 7.2.x: the version range the 5K + GPU reset patches are written and
    # tested against (omarchy-imac18-3 explicitly gates on 7.1.x / 7.2.x).
    # The VCE encoder hang fix (amdgpu-vce3-ring-align-mask) only applies to
    # 7.1.6+, so 7.0.x would miss it; 7.3+ needs a manual patch re-port.
    branch = "7.3"; # branch selects Nixpkgs metadata; argsOverride sets the real version
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper

      # ── Apple 5K dual-tile display (ahmadtv/omarchy-imac18-3) ───────────────
      # Applied in the order the upstream patcher uses them.
      #
      # lean-core: panel-ID quirk, tile-peer wiring, 0x4F1 latch pulse, slave
      # AUX pre-detect, deterministic genlock, reboot handoff. Exposes two proper
      # tiles; a tile-aware compositor (Mutter, KWin) can stitch them natively.
      {
        name = "imac5k-lean-core-7.2.x";
        patch = ./patches/imac5k-lean-core-7.2.x.patch;
      }
      # stitch-layer: presents both 2560×2880 tiles as one 5120×2880 output
      # (amdgpu.tiled_stitch=1). Required for compositors without tile support
      # (GNOME's Mutter should handle tiles natively, but kept for safety).
      {
        name = "imac5k-stitch-layer-7.x";
        patch = ./patches/imac5k-stitch-layer-7.x.patch;
      }
      # hide-slave: with tiled_stitch on, reports the slave connector as
      # disconnected so no compositor or settings panel offers it as a second
      # display. dc_link/sink state is untouched.
      {
        name = "imac5k-stitch-hide-slave";
        patch = ./patches/imac5k-stitch-hide-slave.patch;
      }

      # ── AMD GPU reset fixes (ahmadtv/omarchy-imac18-3) ───────────────────────
      # amdgpu-vce3-ring-align-mask: already in 7.2.14 (align_mask = 0x1f in
      # vce_v3_0_ring_vm_funcs), so this patch is intentionally omitted.
      #
      # Let the GPU actually recover after a VCE hang instead of coming back dead.
      {
        name = "amdgpu-vce-suspend-in-reset";
        patch = ./patches/amdgpu-vce-suspend-in-reset.patch;
      }
      # Prevent dc_lock deadlock during GPU reset (HPD work vs dm_suspend()).
      {
        name = "amdgpu-hpd-skip-during-reset";
        patch = ./patches/amdgpu-hpd-skip-during-reset.patch;
      }

      # ── Intel HD 630: set_os EFI protocol ───────────────────────────────────
      # Adds iMac18,3 to the kernel's apple_match_product_name() list so the EFI
      # stub calls set_os before boot, making Apple firmware expose the Intel HD
      # 630. Only safe alongside i915.disable_display=1 + headless VBT below.
      {
        name = "efi-stub-add-imac18-3-set-os";
        patch = ./patches/efi-stub-add-imac18-3-set-os.patch;
      }
    ];
    argsOverride = {
      src = pkgs.fetchurl {
        url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.2.14.tar.xz";
        hash = "sha256-uxuHHvlajeELP3t7rw4NdUq79iD4BLbK+GDyJqqXZH0=";
      };
      version = "7.2.14";
      modDirVersion = "7.2.14";
      extraMeta.branch = "7.2";
      ignoreConfigErrors = true;
      structuredExtraConfig = with lib.kernel; {
        RUST = mkKernelOverride no;
      };
    };
  };

  imac5kKernelPackages = pkgs.linuxPackagesFor imac5kKernel;

  # Headless Intel VBT — a minimal, valid Intel VBT with NO display outputs.
  # Required for i915.vbt_firmware= so i915 doesn't invent an eDP connector on
  # DDI A (which blanked the Radeon-driven 5K panel on iMac20,1).
  # Source: https://github.com/ahmadtv/omarchy-imac18-3/tree/main/igpu
  headlessVbt = pkgs.runCommand "imac18-3-headless-vbt" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    mkdir -p $out
    python3 ${./make-headless-vbt.py} $out/headless-vbt.bin
  '';

  # Script run once per GPU reset (triggered by the udev rule below).
  # Restarts the display manager so you get a fresh desktop instead of a black
  # screen after the Radeon recovers from a VCE hang.
  gpuResetRecoverScript = pkgs.writeShellScript "imac-gpu-reset-recover" ''
    if ! ${pkgs.systemd}/bin/systemctl is-active --quiet display-manager.service; then
      echo "GPU reset: no display manager running, nothing to restart"
      exit 0
    fi
    # Show a calm VT while the DM restarts.
    chvt 2 2>/dev/null || true
    printf '\033[2J\033[H\n\n   GPU reset -- the graphics session was lost.\n   Restarting the desktop...\n' > /dev/tty2 2>/dev/null || true
    sleep 2
    echo "GPU reset: restarting the display manager so the desktop comes back"
    exec ${pkgs.systemd}/bin/systemctl restart display-manager.service
  '';
in

{
  imports = [
    #./thunderbolt-suspend.nix
  ];

  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

#  environment.systemPackages = (
#    with pkgs;
#    [
#      #    fprintd
#      #    libva-utils
#      #    vdpauinfo
#      #    intel-gpu-tools
#      #    cifs-utils
#    ]
#  )
#  #      ++ (with pkgs-stable; [])
#  #      ++ (with pkgs-unstable; [])
#  # Uncomment either block above to pin specific packages to stable or unstable
#  # regardless of the host's defaultPkgChannel setting (see technitium for an example).
#  ;

  boot = {
    kernelParams = [
      # Activate the stitch layer: presents both 2560×2880 tiles as one
      # 5120×2880 output on the eDP connector.
      "amdgpu.tiled_stitch=1"

      "mem_sleep_default=s2idle"
      "resume_offset=12002560"
      #    "kvm.enable_virt_at_load=0"

      # ── Intel HD 630 (macOS mode / Quick Sync) ──────────────────────────────
      # set_os is handled by the kernel patch above. These params tell i915 to
      # run headless so it doesn't blank the Radeon-driven 5K panel.
      "snd_hda_core.gpu_bind=0"      # prevent speakers vanishing when i915 loads
      "i915.disable_display=1"        # HD 630 headless; Radeon keeps the panel
      "i915.vbt_firmware=imac18-3/headless-vbt.bin"  # no-output VBT for i915
      "module_blacklist=i2c_i801"     # firmware owns SMBus for backlight in macOS mode
    ];
  };
  boot.extraModulePackages = [
    (pkgs.callPackage ./cs8409-module.nix {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = [ "snd_hda_codec_cs8409" ];

  # Install the headless Intel VBT so the kernel can find it via
  # i915.vbt_firmware=imac18-3/headless-vbt.bin
  hardware.firmware = [
    (pkgs.runCommand "imac18-3-vbt-firmware" { } ''
      mkdir -p $out/lib/firmware/imac18-3
      cp ${headlessVbt}/headless-vbt.bin $out/lib/firmware/imac18-3/headless-vbt.bin
    '')
  ];

  # ── UCM config for CS8409/CS42L83 internal mic ──────────────────────────────
  # The generic HDA-Intel UCM gates mic setup on "Capture Switch" which the
  # CS8409 driver doesn't expose (it uses "Internal Mic Capture Switch").
  # Installing a card-specific conf.d entry makes WirePlumber present a real
  # capture source instead of only a monitor of the output.
  environment.etc =
    let
      cardLongName = "HDA Intel PCH at 0x92720000 irq 50";
      ucmBase = "alsa/ucm2/conf.d/HDA-Intel";
      cardConf = builtins.path {
        name = "imac18-3-ucm-card.conf";
        path = ./ucm2 + "/HDA Intel PCH at 0x92720000 irq 50.conf";
      };
    in
    {
      "${ucmBase}/${cardLongName}.conf".source = cardConf;
      "${ucmBase}/${cardLongName}/HiFi.conf".source = ./ucm2/HiFi.conf;
    };

  # ── GPU reset recovery ───────────────────────────────────────────────────────
  # When the Radeon's VCE encoder hangs and the GPU resets, the compositor loses
  # its video memory and keeps drawing nothing. The udev rule fires on the kernel's
  # post-reset event (WEDGED=none = recovered) and the service restarts the display
  # manager, putting you back at a fresh desktop instead of a black screen.
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="amdgpu", ENV{WEDGED}=="none", RUN+="${pkgs.systemd}/bin/systemctl --no-block start imac-gpu-reset-recover.service"
  '';

  systemd.services.imac-gpu-reset-recover = {
    description = "Bring the display manager back after a GPU reset";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${gpuResetRecoverScript}";
    };
  };

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
        # intel-media-driver provides iHD VA-API support for the Intel HD 630
        # (Quick Sync H.264/HEVC encode+decode). Needed once the iGPU is visible
        # via macOS mode (i915 + headless VBT + snd_hda_core.gpu_bind=0).
        intel-media-driver
        #      intel-vaapi-driver  # older i965 driver, not needed for Kaby Lake
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
