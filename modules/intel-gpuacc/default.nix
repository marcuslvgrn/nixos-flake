{
  pkgs,
  lib,
  config,
  ...
}:

{
  # GPU acceleration for intel
  options.intel-gpuacc = {
    enable = lib.mkEnableOption "Enable GPU acceleration for intel";
    # "default" follows this host's defaultPkgChannel; stable/unstable override it.
    libvaDriverName = lib.mkOption {
      type = lib.types.str;
      default = "iHD";
      description = "Driver to use for libva";
    };
    vdpauDriver = lib.mkOption {
      type = lib.types.str;
      default = "va_gl";
      description = "Driver to use for vdpau";
    };

  };

  config = lib.mkIf config.intel-gpuacc.enable {
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = config.intel-gpuacc.libvaDriverName;
      VDPAU_DRIVER = config.intel-gpuacc.vdpauDriver;
    };
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        vpl-gpu-rt
      ];
    };
    environment.systemPackages = (
      with pkgs;
      [
        libva-utils
        vdpauinfo
        intel-gpu-tools
      ]
    )
    #      ++ (with pkgs-stable; [])
    #      ++ (with pkgs-unstable; [])
    # Uncomment either block above to pin specific packages to stable or unstable
    # regardless of the host's defaultPkgChannel setting (see technitium for an example).
    ;

  };
}
