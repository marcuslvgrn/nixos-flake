# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  config,
  #pkgs-stable,
  #pkgs-unstable,
  #inputs,
  ...
}:
with lib;
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
  imports = [
    ./hardware-configuration.nix
    # ./disk-config.nix
    #    ../../services/bluetooth-suspend.nix
  ];

  config = {
    services.desktopManager.gnome.enable = true;
    deskflow.enable = true;
    ssd.enable = true;

    startFirefoxAtLogin = true;
    shutdownApp.enable = true;

    #extraFirefoxExtensions = [
    #  "enhanced-h264ify"
    #];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      open = false;
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

    # Autologin a user
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "lovgren";
    };

    environment.etc."xdg/autostart/deskflow.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Deskflow
      Exec=${lib.getExe pkgs.deskflow}
      Terminal=false
      OnlyShowIn=GNOME;
      X-GNOME-Autostart-enabled=true
    '';

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
  };
}
