{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.bluetooth-suspend = {
    enable = lib.mkEnableOption "bluetooth suspend/resume workaround";
  };

  config = lib.mkIf config.bluetooth-suspend.enable {
    systemd.services.bluetooth-sleep-hook = {
      description = "Unbind and rebind Bluetooth hardware around system sleep";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      unitConfig = {
        DefaultDependencies = false;
        StopWhenUnneeded = true;
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = pkgs.writeShellScript "bluetooth-resume" ''
          echo serial0-0 > /sys/module/hci_uart/drivers/serial:hci_uart_qca/bind
          echo "Bluetooth-resume: Resumed normal operation" > /dev/kmsg
        '';
      };
      path = [ pkgs.bash ];
      script = ''
        echo serial0-0 > /sys/module/hci_uart/drivers/serial:hci_uart_qca/unbind
        echo "Bluetooth-suspend: Suspended operation" > /dev/kmsg
      '';
    };
  };
}
