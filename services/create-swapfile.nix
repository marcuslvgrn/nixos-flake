{ config, lib, pkgs, ... }:

{
  systemd.services = {
    create-swapfile = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "swap-swapfile.swap" ];
      script = ''
        swapfile="/swap/swapfile"
        if [[ -f "$swapfile" ]]; then
          echo "Swap file $swapfile already exists, taking no action"
        else
          ${pkgs.coreutils}/bin/truncate -s 0 /swap/swapfile
          ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile
        fi
      '';
    };
  };
}
