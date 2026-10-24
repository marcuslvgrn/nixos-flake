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

  kodiMceListener = pkgs.writeScript "kodi-mce-listener.py" ''
    #!${pythonWithEvdev}/bin/python3

    import subprocess
    import time

    from evdev import InputDevice, ecodes, list_devices

    device_name = "Nuvoton w836x7hg Infrared Remote Transceiver"
    kodi_command = "/run/current-system/sw/bin/kodi"
    kodi_send_command = "${pkgs.kodi}/bin/kodi-send"
    pgrep_command = "${pkgs.procps}/bin/pgrep"

    recommendations_action = (
        "ActivateWindow(Videos,"
        "plugin://plugin.video.youtube/special/recommendations/"
        "?category_label=Recommendations,return)"
    )

    def kodi_is_running():
        result = subprocess.run(
            [pgrep_command, "-x", "kodi-x11"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return result.returncode == 0

    def open_recommendations():
        if not kodi_is_running():
            print("Starting Kodi...", flush=True)
            subprocess.Popen([kodi_command], start_new_session=True)

            # Wait for Kodi to initialize.
            for _ in range(20):
                time.sleep(1)
                if kodi_is_running():
                    break

        if kodi_is_running():
            print("Opening YouTube Recommendations...", flush=True)
            subprocess.run(
                [kodi_send_command, f"--action={recommendations_action}"],
                check=False,
            )
        else:
            print("Kodi did not start.", flush=True)

    while True:
        device = None
        try:
            device_path = next(
                (
                    path
                    for path in list_devices()
                    if InputDevice(path).name == device_name
                ),
                None,
            )

            if device_path is None:
                print(f"Waiting for {device_name}...", flush=True)
                time.sleep(3)
                continue

            device = InputDevice(device_path)

            print(
                f"Listening for MCE keys on "
                f"{device.name} ({device.path})",
                flush=True,
            )

            
            for event in device.read_loop():
                if event.type != ecodes.EV_KEY or event.value != 1:
                    continue

                if event.code == ecodes.KEY_F12:
                    open_recommendations()
                    continue

                if event.code == ecodes.KEY_ESC:
                    if kodi_is_running():
                        print("Opening YouTube add-on menu...", flush=True)
                        subprocess.run(
                            [
                                kodi_send_command,
                                "--action=ActivateWindow(Videos,plugin://plugin.video.youtube/,return)",
                            ],
                            check=False,
                        )
                    continue

                actions = {
                    ecodes.KEY_X: ("Stop", "Stop"),
                    ecodes.KEY_PLAY: ("Play", "Play"),
                    ecodes.KEY_PAUSE: ("Pause", "Play/Pause"),
                    ecodes.KEY_REWIND: ("PlayerControl(Rewind)", "Rewind"),
                    ecodes.KEY_FASTFORWARD: (
                        "PlayerControl(Forward)",
                        "Fast Forward",
                    ),
                    ecodes.KEY_PREVIOUS: ("PlayerControl(Previous)", "Previous"),
                    ecodes.KEY_NEXT: ("PlayerControl(Next)", "Next"),
                    ecodes.KEY_INFO: ("Info", "Info"),
                }

                if event.code in actions and kodi_is_running():
                    media_action, label = actions[event.code]
                    print(f"Sending {label} to Kodi...", flush=True)
                    subprocess.run(
                        [kodi_send_command, f"--action={media_action}"],
                        check=False,
                    )

        except (OSError, RuntimeError) as exc:
            print(f"IR device unavailable ({exc}); retrying.", flush=True)
            time.sleep(3)
        finally:
            if device is not None:
                device.close()
  '';

  pythonWithEvdev = pkgs.python3.withPackages (ps: [
    ps.evdev
  ]);

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
    systemd.user.services.kodi-mce-listener = {
      description = "Kodi listening to the MCE remote";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pythonWithEvdev}/bin/python3 ${kodiMceListener}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
    users.groups.ir = { };
    users.users.lovgren.extraGroups = [ "ir" ];
    services.udev.extraRules = ''
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Nuvoton w836x7hg Infrared Remote Transceiver", GROUP="ir", MODE="0660"
    '';
    environment.systemPackages = (
      with pkgs;
      [
        v4l-utils
        #])
        # Populate either block to pin specific packages to stable or unstable
        # regardless of the host's isStable setting (see technitium for an example).
        #++ (with pkgs-stable; [
        #
        #])
        #++ (with pkgs-unstable; [
        #
      ]
    );
    systemd.services.nuvoton-ir-keymap = {
      description = "Configure Nuvoton IR remote keymap";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udev-settle.service" ];
      wants = [ "systemd-udev-settle.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.v4l-utils}/bin/ir-keytable \
            -s rc0 \
            -k 0x800f0422=KEY_ENTER \
            -k 0x800f0423=KEY_ESC \
            -k 0x800f040d=KEY_F12 \
            -k 0x800f0419=KEY_X
        '';
        RemainAfterExit = true;
      };
    };
  };
}
