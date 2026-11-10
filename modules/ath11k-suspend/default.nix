{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ath11k-suspend = {
    enable = lib.mkEnableOption "ath11k PCI suspend/resume workaround";
  };

  config = lib.mkIf config.ath11k-suspend.enable {
    systemd.services.ath11k-sleep-hook = {
      description = "Unload and reload ath11k PCI driver around system sleep";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      unitConfig = {
        DefaultDependencies = false;
        StopWhenUnneeded = true;
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = pkgs.writeShellScript "ath11k-resume" ''
          /run/current-system/sw/bin/modprobe ath11k_pci
        '';
      };
      script = ''
        /run/current-system/sw/bin/rmmod ath11k_pci
      '';
    };
  };
}
