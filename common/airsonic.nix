{ config, pkgs, lib, ... }:
let
  cfg = config.flakecfg.airsonic;
  airsonicCfg = config.services.airsonic;
  airsonicAdvancedWar = pkgs.fetchurl {
    url = "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war";
    hash = "sha256-fDWstS076BeXE55aOeMSSZuuYhOLLVAfjRGZRnMksz4=";
  };
in with lib; {
  config = mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      javaPackages.compiler.openjdk11
    ])
    ++
    (with pkgs-stable; [
      
    ])
    ++
    (with pkgs-unstable; [
      
    ]);

    services = {
      ddclient.domains = [
        "${cfg.hostName}"
      ];
      airsonic = {
        enable = true;
        listenAddress = mkDefault "0.0.0.0";
#        contextPath = mkDefault "/airsonic";
#        contextPath = mkDefault "/";
        maxMemory = mkDefault 256;
#        jvmOptions = mkDefault [
#          "-Dserver.servlet.context-path=/airsonic"
#        ];
        #This is needed by airsonic-advanced
        jre = pkgs.javaPackages.compiler.openjdk11;
        war = airsonicAdvancedWar;
      };
      nginx = {
        virtualHosts.${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          locations."${airsonicCfg.contextPath}" = {
#            extraConfig = ''
#              proxy_set_header Host              $proxy_host;
#            '';
            proxyPass = "http://127.0.0.1:${toString airsonicCfg.port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
