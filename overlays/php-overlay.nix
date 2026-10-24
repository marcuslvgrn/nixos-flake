{ nixpkgs-unstable-pkgs, config, system }:
final: prev:
let
  phpPkgs = import nixpkgs-unstable-pkgs {
    inherit config system;
  };
in
{
  # Override PHP packages with versions from nixpkgs-unstable
  php = phpPkgs.php;
  php82 = phpPkgs.php82;
  php83 = phpPkgs.php83;
  php84 = phpPkgs.php84;
  php85 = phpPkgs.php85;
}
