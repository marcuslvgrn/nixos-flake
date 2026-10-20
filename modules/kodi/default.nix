{
  lib,
  config,
  pkgs,
  ...
}:

let
  youtubeKeysScript = pkgs.writeShellScript "kodi-youtube-keys" ''
    set -eu

    exec ${pkgs.python3}/bin/python3 - <<'PYTHON'
    import json
    import os
    from pathlib import Path

    secrets_dir = Path("/run/secrets/kodi-youtube")
    addon_dir = Path.home() / ".kodi/userdata/addon_data/plugin.video.youtube"
    output = addon_dir / "api_keys.json"

    api_key = (secrets_dir / "api_key").read_text().strip()
    client_id = (secrets_dir / "client_id").read_text().strip()
    client_secret = (secrets_dir / "client_secret").read_text().strip()

    suffix = ".apps.googleusercontent.com"
    if client_id.endswith(suffix):
        client_id = client_id[:-len(suffix)]

    data = {
        "keys": {
            "developer": {
                "key": api_key,
                "client_id": client_id,
                "client_secret": client_secret,
            }
        }
    }

    addon_dir.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(".json.tmp")

    try:
        with temporary.open("w") as f:
            os.chmod(temporary, 0o600)
            json.dump(data, f, indent=2)
            f.write("\n")
        os.replace(temporary, output)
        os.chmod(output, 0o600)
    finally:
        temporary.unlink(missing_ok=True)
    PYTHON
  '';

  pythonWithEvdev = pkgs.python3.withPackages (ps: [
    ps.evdev
  ]);

  xboxKodiListener = pkgs.writeScript "xbox-kodi-listener.py" ''
    #!${pythonWithEvdev}/bin/python3

    import subprocess
    import time

    from evdev import InputDevice, ecodes

    device_path = (
        "/dev/input/by-id/"
        "usb-©Microsoft_Xbox_360_Wireless_Receiver_for_Windows_"
        "E079BF00-event-joystick"
    )

    kodi_command = "/run/current-system/sw/bin/kodi"
    kodi_send_command = "${pkgs.kodi-gbm}/bin/kodi-send"
    pgrep_command = "${pkgs.procps}/bin/pgrep"

    def kodi_is_running():
        result = subprocess.run(
            [pgrep_command, "-x", "kodi-x11"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return result.returncode == 0

    def launch_kodi():
        if kodi_is_running():
            print(
                "Kodi is already running; not launching another instance.",
                flush=True,
            )
            return

        print("Starting Kodi...", flush=True)
        subprocess.Popen(
            [kodi_command],
            start_new_session=True,
        )

        # Wait for Kodi to initialize before opening YouTube.
        time.sleep(2)

        if kodi_is_running():
            print("Opening YouTube...", flush=True)
            subprocess.run(
                [
                    kodi_send_command,
                    "--action=ActivateWindow(Videos,plugin://plugin.video.youtube/special/recommendations/?category_label=Recommendations,return)",
                ],
                check=False,
            )
        else:
            print(
                "Kodi did not start; skipping YouTube launch.",
                flush=True,
            )

    while True:
        try:
            print(f"Opening controller: {device_path}", flush=True)
            device = InputDevice(device_path)

            print(
                f"Listening to {device.name} ({device.path})",
                flush=True,
            )

            for event in device.read_loop():
                if (
                    event.type == ecodes.EV_KEY
                    and event.code == ecodes.BTN_START
                    and event.value == 1
                ):
                    launch_kodi()

        except (OSError, RuntimeError) as exc:
            print(
                f"Controller unavailable ({exc}); retrying in 3 seconds.",
                flush=True,
            )
            time.sleep(3)

        except KeyboardInterrupt:
            break

  '';
in
with lib;
{
  options = {
    kodi.enable = mkEnableOption "Enable Kodi or not";
  };
  config = mkIf config.kodi.enable {
    sops.secrets = {
      "kodi-youtube/api_key" = {
        owner = "lovgren";
        mode = "0400";
      };

      "kodi-youtube/client_id" = {
        owner = "lovgren";
        mode = "0400";
      };

      "kodi-youtube/client_secret" = {
        owner = "lovgren";
        mode = "0400";
      };
    };

    systemd.user.services.kodi-youtube-keys = {
      description = "Install Kodi YouTube API keys";

      wantedBy = [ "default.target" ];

      after = [ "sops-nix.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = youtubeKeysScript;
      };
    };

    services.xserver.desktopManager.kodi = {
      enable = true;

      package = pkgs.kodi.withPackages (
        kodiPkgs: with kodiPkgs; [
          (youtube.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              file="$out/share/kodi/addons/plugin.video.youtube/resources/lib/youtube_plugin/youtube/client/player_client.py"

              if [ ! -f "$file" ]; then
                echo "YouTube player_client.py not found: $file" >&2
                exit 1
              fi

              sed -i "/^[[:space:]]*'android_vr',/s/^/# disabled by NixOS workaround: /" "$file"
            '';
          }))

          inputstream-adaptive
          joystick
        ]
      );
    };
    systemd.user.services.xbox-kodi-listener = {
      description = "Launch Kodi using Xbox 360 controller Start button";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pythonWithEvdev}/bin/python3 ${xboxKodiListener}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
