{
  config,
  lib,
  pkgs,
  ...
}:

let
  btrfs-map-physical = pkgs.stdenv.mkDerivation {
    pname = "btrfs-map-physical";
    version = "0-unstable-2026-11-02";

    src = pkgs.fetchFromGitHub {
      owner = "simonhughxyz";
      repo = "btrfs-map-physical";
      rev = "2221a797472b5cb9e0cc297e91ac28712e029943";
      hash = "sha256-qVzFTPoiHBOrt4u+U4gppKu9yvE+dNDxFLNSIo+Fxz8=";
    };

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      make all
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 btrfs-map-physical \
        "$out/bin/btrfs-map-physical"
      runHook postInstall
    '';

    meta = {
      description = "Map logical and physical extents of Btrfs files";
      homepage = "https://github.com/simonhughxyz/btrfs-map-physical";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "btrfs-map-physical";
    };
  };
  get-resume-offset = pkgs.writeShellApplication {
    name = "get-resume-offset";

    runtimeInputs = [
      btrfs-map-physical
      pkgs.coreutils
      pkgs.glibc.bin
      pkgs.gnused
    ];

    text = ''
      physical_offset="$(
        /run/wrappers/bin/sudo btrfs-map-physical \
        ${lib.escapeShellArg config.programs.get-resume-offset.swapfile} |
          cut -f9 |
          sed -n '2p'
      )"
      pagesize="$(getconf PAGESIZE)"

      if [[ ! "$physical_offset" =~ ^[0-9]+$ ]]; then
        echo "Could not read a numeric physical offset" >&2
        exit 1
      fi

      echo "$((physical_offset / pagesize))"
    '';
  };
in
{
  options.programs.get-resume-offset = {
    enable = lib.mkEnableOption "Helper to calculate resume offset from /swap/swapfile";
    swapfile = lib.mkOption {
      type = lib.types.str;
      description = "swapfile location";
      default = "/swap/swapfile";
    };
  };

  config = lib.mkIf config.programs.get-resume-offset.enable {
    environment.systemPackages = [
      get-resume-offset
    ];
  };
}
