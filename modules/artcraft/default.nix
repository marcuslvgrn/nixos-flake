{
  config,
  lib,
  inputs,
  ...
}:
let
  appNames = [
    "photocraft"
    "vectorcraft"
    "designcraft"
    "lightcraft"
    "filmcraft"
    "effectcraft"
    "pdfcraft"
  ];
  defaultApps = [
    "photocraft"
    "pdfcraft"
  ];
in
{
  imports = [
    inputs.artcraft.nixosModules.default
  ];

  options.artcraft.apps = lib.genAttrs appNames (app: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem app defaultApps;
      description = "Whether to install ArtCraft's ${app} app.";
    };
  });

  config.programs.artcraft.apps = lib.mkDefault (
    builtins.filter (app: config.artcraft.apps.${app}.enable) appNames
  );
}
