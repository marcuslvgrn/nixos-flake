final: prev:
let
  version = "15.0.1";
in
{
  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: {
    inherit version;
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "TechnitiumLibrary";
      tag = "v${version}";
      hash = "sha256-U6Hpg2HMd8o+vXuu4XQo2P5sZDyQ5jPiU3+oPw/rsPs=";
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
      tag = "v${version}";
      hash = "sha256-U6Hpg2HMd8o+vXuu4XQo2P5sZDyQ5jPiU3+oPw/rsPs=";
      name = "${old.pname}-${version}";
    };
  });
}
