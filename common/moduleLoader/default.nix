
# This file is a function that takes a path and returns a NixOS/home-manager
# module which auto-imports all immediate subdirectories of that path.
#
# Usage: call this file with `{ inherit lib; }` and pass the directory path:
#
#   (import /path/to/this/file { inherit lib; }) ./.
#
# Each subdirectory is expected to contain a default.nix (or be a valid module
# path). Subdirectories are sorted alphabetically to ensure a reproducible and
# deterministic load order.

{ lib }:
path:
let
  # builtins.readDir returns an attrset of { name = type } for all entries in
  # the given directory, where type is "regular", "directory", "symlink", etc.
  # We filter to only keep directories, then extract their names as a list.
  subdirs = lib.sort lib.lessThan (
    builtins.attrNames (
      lib.filterAttrs (_: type: type == "directory") (builtins.readDir path)
    )
  );
in
{
  # Build an import list by appending each subdirectory name to the given path.
  # Nix will look for a default.nix inside each subdirectory.
  imports = map (name: path + "/${name}") subdirs;
}
