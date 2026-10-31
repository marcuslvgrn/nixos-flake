{
  pkgs,
  config,
  lib,
  ...
}:
let
  driver = config.hardware.nvidia.package;

  # patchelf 0.18/0.19 can leave nvidia-smi's .dynamic section
  # in a read-only LOAD segment. Use 0.15.0 for this executable.
  patchelf_0_15 = pkgs.patchelf.overrideAttrs (_: {
    version = "0.15.0";
    src = pkgs.fetchurl {
      url = "https://github.com/NixOS/patchelf/releases/download/0.15.0/patchelf-0.15.0.tar.bz2";
      hash = "sha256-9ANtPuTY4ijewb7/8PbkbYpA6eVw4AaOOdd+YuLIvcI=";
    };
    patches = [ ];
    doCheck = false;
  });

  nvidiaSmi =
    pkgs.runCommand "nvidia-smi-fixed-${driver.version}"
      {
        nativeBuildInputs = [
          patchelf_0_15
          pkgs.zstd
        ];
      }
      ''
        set -euo pipefail

        skip=$(sed -n 's/^skip=//p' ${driver.src})
        test -n "$skip"

        tail -n +"$skip" ${driver.src} |
          zstd -d |
          tar xf - nvidia-smi

        install -Dm755 nvidia-smi "$out/bin/nvidia-smi"

        patchelf \
          --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} \
          --set-rpath "$(patchelf --print-rpath ${lib.getBin driver}/bin/nvidia-smi)" \
          "$out/bin/nvidia-smi"
      '';

in
{
  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9d53dc2e-eb10-4124-8e68-a831ad02e217";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:1"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9d53dc2e-eb10-4124-8e68-a831ad02e217";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:1"
    ];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/5216-CAAD";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = (
      with pkgs;
      [
        nvidia-vaapi-driver
        #libvdpau-va-gl
        #vpl-gpu-rt
        #])
        #++ (with pkgs-stable; [
        #
        #       ])
        #      ++ (with pkgs-unstable; [
        #
      ]
    );
  };
  environment.systemPackages = (
    with pkgs;
    [
      libva-utils
      vdpauinfo
      (lib.hiPrio nvidiaSmi)
      nvtopPackages.full
      #])
      # Populate either block to pin specific packages to stable or unstable
      # regardless of the host's defaultPkgChannel setting (see technitium for an example).
      #++ (with pkgs-stable; [
      #
      #])
      #++ (with pkgs-unstable; [
      #
    ]
  );

  networking.interfaces.enp3s0.wakeOnLan.enable = true;

}
