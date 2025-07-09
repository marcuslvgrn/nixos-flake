{ config, lib, pkgs, modulesPath, ... }:

{
systemd.services.bluetooth-resume= {
  serviceConfig.Type = "oneshot";
  wantedBy = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
  after = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
  path = with pkgs; [ bash ];
  script = ''
    echo serial0-0 > /sys/module/hci_uart/drivers/serial:hci_uart_qca/bind
    echo "Bluetooth-resume: Resumed normal operation" > /dev/kmsg
    '';          
};

systemd.services.bluetooth-suspend= {
  serviceConfig.Type = "oneshot";
  wantedBy = [ "sleep.target" ];
  after = [ "sleep.target" ];
  path = with pkgs; [ bash ];
  script = ''
    echo serial0-0 > /sys/module/hci_uart/drivers/serial:hci_uart_qca/unbind
    echo "Bluetooth-suspend: Suspeneded operation" > /dev/kmsg
    '';          
};

}
