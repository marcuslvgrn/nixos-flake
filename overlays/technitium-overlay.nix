final: prev:
{
  technitium-dns-server =
    prev.technitium-dns-server.overrideAttrs (old: let
      version = "14.3.0";
    in {
      inherit version;

      name = "${old.pname}-${version}";

      src = old.src.override {
        tag = "v${version}";
        hash = "sha256-NUH1gn8kdtMBKC5+XEqqTGySNMCDFGF5yy6NbGeRvvY=";
      };
    });
}
