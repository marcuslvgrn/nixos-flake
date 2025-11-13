{ config, pkgs, lib, ... }:

{
  services.airsonic = {
    enable = true;
    listenAddress = "192.168.0.117";
    contextPath = "/airsonic";
    jvmOptions = [
      "-Dserver.use-forward-headers=true"
    ];
  };
}
