{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.airsonic;
  serviceCfg = config.services.airsonic;
  airsonicAdvancedWar = pkgs.fetchurl {
    url = "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war";
    hash = "sha256-fDWstS076BeXE55aOeMSSZuuYhOLLVAfjRGZRnMksz4=";
  };
in
with lib;
{

  options = {
    airsonic = {
      hostName = mkOption {
        type = types.str;
        default = "";
        description = "Hostname for airsonic nginx";
      };
    };
  };

  config = mkIf serviceCfg.enable {
    assertions = [
      {
        assertion = cfg.hostName != "";
        message = "Set airsonic.hostName when services.airsonic.enable is true.";
      }
    ];

    services = {
      ddclient.domains = [
        "${cfg.hostName}"
      ];
      airsonic = {
        maxMemory = mkDefault 256;
        virtualHost = cfg.hostName;
        # NixOS sets the legacy server.context-path property; Airsonic Advanced 11.x uses server.servlet.context-path.
        jvmOptions = mkAfter [
          "-Dserver.servlet.context-path=${serviceCfg.contextPath}"
          # Make Airsonic Advanced honor X-Forwarded-* headers from nginx when generating URLs.
          "-Dserver.forward-headers-strategy=native"
        ];
        # Airsonic Advanced 11.x requires Java 11 or newer.
        jre = pkgs.javaPackages.compiler.openjdk11;
        war = airsonicAdvancedWar;
      };
      nginx = {
        virtualHosts.${cfg.hostName} = {
          forceSSL = true;
          enableACME = true;
          # Airsonic Advanced uses WebSockets for its UI behind the reverse proxy.
          locations.${serviceCfg.contextPath}.proxyWebsockets = true;
        };
      };
    };
  };
}
