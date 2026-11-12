{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wakezilla;
  wakezilla = pkgs.rustPlatform.buildRustPackage {
    pname = "wakezilla";
    version = "0.2.14";

    src = pkgs.fetchFromGitHub {
      owner = "guibeira";
      repo = "wakezilla";
      rev = "655561e0eb9d497ae82304a6494d9c6e88c4aae2";
      hash = "sha256-RPNbuHI0e+d/rRh+xbUfV45c5gEW7uM4XuEnkrSTW8I=";
    };

    cargoHash = "sha256-v+PYSOw5LLzGdkHVfT9u+FBsnX3JmY4vY8gxgzeucq8=";

    buildFeatures = [ "desktop-tray" ];

    nativeBuildInputs = with pkgs; [
      pkg-config
      makeWrapper
      trunk
      wasm-bindgen-cli_0_2_104
      lld
      binaryen
    ];

    buildInputs = with pkgs; [
      gtk3
      libayatana-appindicator
    ];

    # The upstream build script expects rustup to install a nightly compiler
    # and wasm target. Nix supplies both from its Rust toolchain instead.
    postPatch = ''
      substituteInPlace build.rs \
        --replace-fail '    if !toolchain_installed("nightly") {' '    if false {' \
        --replace-fail '    if !target_installed("nightly", "wasm32-unknown-unknown") {' '    if false {'
      sed -i '/^\[toolchain\]/,+1d' frontend/Trunk.toml
    '';

    RUSTUP_TOOLCHAIN = "stable";

    preBuild = ''
      export HOME="$TMPDIR"
      export XDG_CACHE_HOME="$TMPDIR/.cache"
      mkdir -p "$XDG_CACHE_HOME"
    '';

    postInstall = ''
      for executable in wakezilla wakezilla-tray; do
        wrapProgram "$out/bin/$executable" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.libayatana-appindicator ]}"
      done
    '';

    doCheck = false;

    meta = {
      description = "Wake-on-LAN and reverse proxy toolkit";
      homepage = "https://github.com/guibeira/wakezilla";
      license = lib.licenses.mit;
      mainProgram = "wakezilla";
      platforms = lib.platforms.linux;
    };
  };
in
{
  options.programs.wakezilla = {
    server.enable = lib.mkEnableOption "the Wakezilla proxy server";
    client = {
      enable = lib.mkEnableOption "the Wakezilla client server";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3001;
        description = "Port used by the Wakezilla client server.";
      };
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Optional systemd EnvironmentFile for the Wakezilla client. Store
          shutdown credentials in a SOPS-managed file, not in Nix expressions.
        '';
      };
    };
    tray.enable = lib.mkEnableOption "the Wakezilla desktop tray";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.server.enable || cfg.client.enable || cfg.tray.enable) {
      environment.systemPackages = [ wakezilla ];
    })

    (lib.mkIf cfg.server.enable {
      networking.firewall.allowedTCPPorts = [ 3000 ];

      systemd.services.wakezilla-proxy = {
        description = "Wakezilla Wake-on-LAN proxy server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${wakezilla}/bin/wakezilla --no-update-check proxy-server";
          Restart = "on-failure";
          RestartSec = 5;

          DynamicUser = true;
          StateDirectory = "wakezilla";
          WorkingDirectory = "/var/lib/wakezilla";

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
        };
      };
    })

    (lib.mkIf cfg.client.enable {
      networking.firewall.allowedTCPPorts = [ cfg.client.port ];

      sops.secrets."wakezilla-client-env" = { };
      programs.wakezilla.client.environmentFile = config.sops.secrets."wakezilla-client-env".path;

      systemd.services.wakezilla-client = {
        description = "Wakezilla client server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment.WAKEZILLA__SERVER__CLIENT_PORT = toString cfg.client.port;

        serviceConfig = {
          Type = "simple";
          ExecStart = "${wakezilla}/bin/wakezilla --no-update-check client-server";
          EnvironmentFile = lib.optional (cfg.client.environmentFile != null) cfg.client.environmentFile;
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    })

    (lib.mkIf cfg.tray.enable {
      systemd.user.services.wakezilla-tray = {
        description = "Wakezilla desktop tray";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${wakezilla}/bin/wakezilla --no-update-check tray";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    })
  ];
}
