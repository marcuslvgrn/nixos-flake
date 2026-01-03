{ config, pkgs, lib, ... }:
let
  cfg = config.services.airsonicNginx;
  airsonicCfg = config.services.airsonic;
in with lib; {
  options.services.airsonicNginx = {
    enable = mkEnableOption "Airsonic behind Nginx with ACME";
    #     listenAddress = mkOption {
    #       type = types.str;
    #       default = "0.0.0.0";
    #       description = "IP address Airsonic listens on";
    #     };
    #     contextPath = mkOption {
    #       type = types.str;
    #       default = "/";
    #       description = "context path for the Airsonic server";
    #     };
    #     jvmOptions = mkOption {
    #       type = types.listOf types.str;
    #       default = [ "-Dserver.use-forward-headers=true" ];
    #       description = "Enables forward headers for nginx";
    #     };
    #     maxMemory = mkOption {
    #       type = types.int;
    #       default = 256;
    #       description = "Allows a bit more memory for Airsonic";
    #     };
    hostName = mkOption {
      type = types.str;
      #        default = "mlairsonic.dynv6.net";
      description = "Public hostname for nginx";
    };
    #      proxyAddress = mkOption {
    #        type = types.str;
    #        default = "127.0.0.1";
    #        description = "Address for nginx to proxy to";
    #      };
  };
  
  config = mkIf cfg.enable {
    services = {
      ddclient.domains = [
        "${cfg.hostName}"
      ];
      airsonic = {
        enable = true;
        #          listenAddress = cfg.listenAddress;
        #          contextPath = cfg.contextPath;
        #          jvmOptions = cfg.jvmOptions;
        #          maxMemory = cfg.maxMemory;
        listenAddress = mkDefault "0.0.0.0";
        contextPath = mkDefault "/";
        jvmOptions = mkDefault [ "-Dserver.use-forward-headers=true" ];
        maxMemory = mkDefault 256;
      };
      nginx = {
#        recommendedProxySettings = true;
#        recommendedTlsSettings = true;
#        recommendedOptimisation = true;
#        recommendedGzipSettings = true;
        virtualHosts.${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          locations."${airsonicCfg.contextPath}" = {
            proxyPass = "http://127.0.0.1:${toString airsonicCfg.port}";
          };
        };
      };
    };
  };
}
