{ pkgs, ... }:

let
  rebindScript = pkgs.writeShellScript "thunderbolt-rebind" ''
    set -eu

    dev="0000:07:00.0"
    device="/sys/bus/pci/devices/$dev"
    driver="/sys/bus/pci/drivers/thunderbolt"
    marker="/run/thunderbolt-unbind-$dev"

    if [ -e "$marker" ] && [ -d "$device" ]; then
      printf '%s' "$dev" > "$driver/bind"
      echo "thunderbolt-unbind: rebound $dev"
      ${pkgs.coreutils}/bin/rm -f "$marker"
    else
      echo "thunderbolt-unbind: no marker or device missing; not rebinding"
    fi
  '';
in
{
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  systemd.sleep.settings.Sleep.MemorySleepMode = "s2idle";

  environment.etc."systemd/system-sleep/thunderbolt-unbind" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      set -eu

      dev="0000:07:00.0"
      device="/sys/bus/pci/devices/$dev"
      driver="/sys/bus/pci/drivers/thunderbolt"
      marker="/run/thunderbolt-unbind-$dev"

      case "$1:$2" in
        pre:suspend)
          echo "thunderbolt-unbind: pre-suspend"

          if [ -L "$driver/$dev" ]; then
            printf '%s' "$dev" > "$driver/unbind"
            : > "$marker"
            echo "thunderbolt-unbind: unbound $dev; waiting 5 seconds"
            ${pkgs.coreutils}/bin/sleep 5
            echo "thunderbolt-unbind: delay finished"
          else
            echo "thunderbolt-unbind: $dev is not bound to thunderbolt"
          fi
          ;;

        post:suspend)
          if [ -e "$marker" ]; then
            echo "thunderbolt-unbind: scheduling rebind in 20 seconds"
            ${pkgs.systemd}/bin/systemd-run --system --no-block --collect \
              --unit="thunderbolt-rebind-$$" --on-active=20s \
              ${rebindScript}
          else
            echo "thunderbolt-unbind: no unbind marker; nothing to schedule"
          fi
          ;;
      esac
    '';
  };
}
