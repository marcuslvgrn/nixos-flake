{
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
}:
{
  # Shared option type for package modules: follow the host default, or pin a channel.
  type = lib.types.enum [
    "default"
    "stable"
    "unstable"
  ];

  # Return the host's default package set for "default", otherwise the chosen set.
  forChannel =
    channel:
    if channel == "default" then
      (if hostSettings.defaultPkgChannel == "stable" then pkgs-stable else pkgs-unstable)
    else if channel == "stable" then
      pkgs-stable
    else
      pkgs-unstable;
}
