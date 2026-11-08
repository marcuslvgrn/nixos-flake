{
  lib,
  nixosConfig,
  pkgs,
  config,
  #  pkgs-unstable,
  ...
}:

{
  imports = [ ];

  config = lib.mkIf nixosConfig.omarchy.enable {
    # Enable home manager omarchy module
    omarchy.enable = true;
 
    # Omarchy owns shell.json as an editable runtime file and has no module
    # option for individual widgets. Preserve its current and future settings,
    # while enforcing just this one preference after Home Manager writes files.
    home.activation.omarchyHideSystemUpdateWidget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      shell_config="$HOME/.config/omarchy/shell.json"
      if [ -f "$shell_config" ]; then
        shell_config_tmp=$(mktemp "$shell_config.XXXXXX")
        ${pkgs.jq}/bin/jq '(.bar.layout |= with_entries(.value |= map(select(.id != "omarchy.system-update"))))' \
          "$shell_config" >"$shell_config_tmp"
        if ! cmp -s "$shell_config" "$shell_config_tmp"; then
          chmod --reference="$shell_config" "$shell_config_tmp"
          run mv "$shell_config_tmp" "$shell_config"
        else
          run rm -f "$shell_config_tmp"
        fi
      fi
    '';

    # Omarchy's first-run provisioner retries all onboarding notifications when
    # any step fails. First-run setup has already run; this marker prevents the
    # repeated Learn Keybindings toast at each login.
    home.file.".local/state/omarchy/done/first-run-user".text = "";

    xdg.configFile."hypr/input.lua" = lib.mkIf nixosConfig.programs.hyprland.enable {
      force = true;
      text = ''
        hl.config({
          input = {
            kb_layout = "se",
            touchpad = {
              natural_scroll = true,
            },
          },
        })
      '';
    };
  };

  #  nixpkgs = {
  #    # You can add overlays here
  #    overlays = [
  #      # If you want to use overlays exported from other flakes:
  #      # neovim-nightly-overlay.overlays.default
  #
  #      # Or define it inline, for example:
  #      # (final: prev: {
  #      #   hi = final.hello.overrideAttrs (oldAttrs: {
  #      #     patches = [ ./change-hello-to-hi.patch ];
  #      #   });
  #      # })
  #    ];
  #    # Configure your nixpkgs instance
  #    config = {
  #      # Disable if you don't want unfree packages
  #      allowUnfree = true;
  #      # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #      allowUnfreePredicate = _: true;
  #    };
  #  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Nicely reload system units when changing configs
  #  systemd.user.startServices = "sd-switch";
  #
}
