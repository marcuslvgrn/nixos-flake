{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.create-swapfile = {
    enable = lib.mkEnableOption "swap-file creation service";
  };

  config = lib.mkIf config.create-swapfile.enable {
    systemd.services = {
      create-swapfile = {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "swap-swapfile.swap" ];
        script = ''
          swapfile="/swap/swapfile"
          if [[ -f "$swapfile" ]]; then
            echo "Swap file $swapfile already exists, taking no action"
          else
            /run/current-system/sw/bin/mkdir -p /swap
            ${pkgs.coreutils}/bin/truncate -s 0 /swap/swapfile
            ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile
          fi
        '';
      };
    };
  };
}
