final: prev:
let
  version = "14.3.0";
in
{
  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: {
    inherit version;
    src = old.src.override {
      hash = "";
    };
  });
  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: {
    inherit version;
    src = old.src.override {
      hash = "";
    };
  });
}
