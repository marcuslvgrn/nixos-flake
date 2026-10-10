
# Auto-import all subdirectories in this folder as NixOS modules.
# The loader function lives in common/moduleLoader and takes an explicit path,
# so ./.  here unambiguously refers to this directory (modules/).
{ lib, ... }:
(import ../common/moduleLoader { inherit lib; }) ./.
