{ config, lib, pkgs, ... }:

{
systemd.services.ath11k-resume= {
  serviceConfig.Type = "oneshot";
  wantedBy = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
  after = [ "suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target" ];
  path = with pkgs; [ bash ];
  script = ''
    /run/current-system/sw/bin/modprobe ath11k_pci
    '';          
};

systemd.services.ath11k-suspend= {
  serviceConfig.Type = "oneshot";
  wantedBy = [ "sleep.target" ];
  after = [ "sleep.target" ];
  path = with pkgs; [ bash ];
  script = ''
    /run/current-system/sw/bin/rmmod ath11k_pci
    '';          
};

}
