{
  config,
  hostSettings,
  inputs,
  lib,
  ...
}:
let
  nixarchyInput =
    if hostSettings.nixarchyChannel == "release" then inputs.nixarchy-release else inputs.nixarchy-edge;
in
{
  # Import upstream unconditionally so its enable option is available to each
  # host configuration. The upstream option itself controls whether it is active.
  imports = [ nixarchyInput.nixosModules.nixarchy ];

  config = {
    # Keep the matching Home Manager options available; upstream enablement
    # controls whether Nixarchy's Home Manager configuration is applied.
    home-manager.sharedModules = [ nixarchyInput.homeManagerModules.nixarchy ];
    home-manager.users.lovgren = {
      programs.nixarchy.enable = true;
    };

    assertions = lib.optionals config.programs.nixarchy.enable [
      {
        assertion = !(config.omarchy.enable && (config.programs.nixarchy.enable or false));
        message = "Enable either omarchy.enable or programs.nixarchy.enable, not both.";
      }
    ];

    programs.nixarchy.flake = lib.mkIf config.programs.nixarchy.enable (
      lib.mkDefault config.omarchy.nixFlakePath
    );

    # Use the host's existing display manager (GDM in this flake) instead of
    # having Nixarchy enable a second SDDM instance.
    programs.nixarchy.displayManager = lib.mkForce false;
  };
}
