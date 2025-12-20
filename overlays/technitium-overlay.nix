#final: prev:
#{
#  technitium-dns-server =
#    prev.technitium-dns-server.overrideAttrs (old: let
#      version = "14.3.0";
#    in {
#      inherit version;
#
#      name = "${old.pname}-${version}";
#
#      src = old.src.override {
#        tag = "v${version}";
#        hash = "sha256-NUH1gn8kdtMBKC5+XEqqTGySNMCDFGF5yy6NbGeRvvY=";
#      };
#    });
#}
#
#{ lib, fetchurl, stdenv, ... }:

self: super: {
  technitium-dns-server = super.stdenv.mkDerivation {
    pname = "technitium-dns-server";
    version = "14.3.0";

    src = super.fetchurl {
#      url = "https://github.com/TechnitiumSoftware/DnsServer/releases/download/v${version}/TechnitiumDNS-Server-x64.tar.gz";
      url = "https://github.com/TechnitiumSoftware/DnsServer/releases/download/v14.3.0/TechnitiumDNS-Server-x64.tar.gz";
      # Replace this with the real sha256 after the first build attempt
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    nativeBuildInputs = [ ];

    # Technitium is a prebuilt binary, no build needed
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
    '';

    meta = with super.lib; {
      description = "Technitium DNS Server (prebuilt binary)";
      homepage = "https://technitium.com/dns/";
      license = licenses.mit;
      maintainers = [ maintainers.lovgren ];
    };
  };

}
