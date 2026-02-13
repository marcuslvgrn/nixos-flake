{ lib, ... }:
let
  #readDir creates an attribute set like file/dirname = regular/directory for each entry
  #then filter out directories
  #then return a list of the names, not the values
  #then sort alphabetically to ensure reproducible load order
  #result is a list of subdirectories
  subdirs = lib.sort lib.lessThan (
    builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.))
  );
in
{
  #for each directory, return the path to it
  imports = map (name: ./. + "/${name}") subdirs;
}
