final: prev:
let
  version = "15.5.1";
in
{
  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: {
    inherit version;
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "TechnitiumLibrary";
      tag = "dns-server-v${version}";
      hash = "sha256-GkHHAXfmT1MUSIG8zsPHBxtpKVSV7KMONLHy00lk10Y=";
      name = "${old.pname}-${version}";
    };
    projectFile = [
      "src/TechnitiumLibrary/TechnitiumLibrary.csproj"
    ];
  });
  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: {
    inherit version;
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "DnsServer";
      tag = "dns-server-v${version}";
      hash = "sha256-h6GhWVqv+SRpJberH/xJ2bny1j+RFM7FI1E+LxuhLOw=";
      name = "${old.pname}-${version}";
    };
  });
}
