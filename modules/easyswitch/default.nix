{
  config,
  lib,
  pkgs,
  ...
}:

let
  easyswitch = pkgs.stdenv.mkDerivation rec {
    pname = "easyswitch";
    version = "0.1.0";

    src = pkgs.fetchurl {
      # If this release URL changes, use the Linux tar.gz asset linked
      # from the project's GitHub Releases page.
      url = "https://github.com/developersharif/easyswitch-app/releases/download/v${version}-b154/easyswitch-${version}-linux-x64.tar.gz";
      hash = "sha256-JitG+Lq/i4zE24KYmXDmUeRl/b9UyfuTZBK/g5mnbz4=";
    };

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      libxkbcommon
      libGL
      wayland
      libx11
      libxcursor
      libxrandr
      libxi
      libxrender
      libxcb
      mesa
      libva
      pipewire
      fontconfig
    ];

    sourceRoot = ".";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/easyswitch $out/bin
      cp -a ./. $out/lib/easyswitch/

      chmod +x $out/lib/easyswitch/easyswitch
      makeWrapper $out/lib/easyswitch/easyswitch $out/bin/easyswitch \
        --chdir $out/lib/easyswitch \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            pkgs.wayland
            pkgs.libxkbcommon
          ]
        }"

      runHook postInstall
    '';

    meta = {
      description = "Software KVM for sharing keyboard and mouse across computers";
      homepage = "https://easyswitch.realbrain.cc/";
      platforms = [ "x86_64-linux" ];
      mainProgram = "easyswitch";
    };
  };
in
{
  options.services.easyswitch = {
    enable = lib.mkEnableOption "EasySwitch";
    user = lib.mkOption {
      type = lib.types.str;
      description = "User allowed to access /dev/uinput";
    };
  };

  config = lib.mkIf config.services.easyswitch.enable {
    environment.systemPackages = [ easyswitch ];

    # EasySwitch uses uinput for input injection.
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';

    networking.firewall.allowedTCPPorts = [ 41420 ];
    networking.firewall.allowedUDPPorts = [ 41417 5353 ];

    users.groups.input = { };
    users.users.${config.services.easyswitch.user or "your-username"}.extraGroups = [ "input" ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    services.pipewire.enable = true;
  };
}
