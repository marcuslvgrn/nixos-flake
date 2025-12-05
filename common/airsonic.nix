{ config, pkgs, lib, ... }:

{
  services.airsonic = {
    enable = true;
    listenAddress = "192.168.0.7";
    contextPath = "/";
    jvmOptions = [
      "-Dserver.use-forward-headers=true"
    ];
    maxMemory = 256;
  };
}
