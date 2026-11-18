{
  lib,
  nixosConfig,
  pkgs,
  config,
  #  pkgs-unstable,
  ...
}:
let
  footTmuxStart = pkgs.writeShellApplication {
    name = "foot-tmux-start";
    runtimeInputs = [ pkgs.tmux ];
    text = ''
      session="foot-workspace"

      if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -n nixos-flake -c "$HOME/git/nixos-flake" nvim
        tmux new-window -d -t "$session":2 -n nixos-flake-shell -c "$HOME/git/nixos-flake"
        tmux new-window -d -t "$session":3 -n home -c "$HOME"
        tmux select-window -t "$session":1
      fi

      exec tmux attach-session -t "$session"
    '';
  };
in
{
  imports = [ ];

  config = lib.mkMerge [
    (lib.mkIf nixosConfig.omarchy.enable {
      # Enable home manager omarchy module
      omarchy.enable = true;

      # Omarchy's keybinding resolver uses `lua -E`, which Lua 5.1 does not
      # support. Use nixpkgs' current Lua alias and put it first in the
      # graphical session PATH so plugins can read effective Hyprland binds.
      home.packages = [ pkgs.lua ];
      home.sessionPath = [ "${pkgs.lua}/bin" ];

      # Omarchy owns shell.json as an editable runtime file and has no module
      # option for individual widgets. Preserve its current and future settings,
      # while enforcing just this one preference after Home Manager writes files.
      home.activation.omarchyHideSystemUpdateWidget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        shell_config="$HOME/.config/omarchy/shell.json"
        if [ -f "$shell_config" ]; then
          shell_config_tmp=$(mktemp "$shell_config.XXXXXX")
          ${pkgs.jq}/bin/jq '(.idle.screensaver = 600) | (.bar.layout |= with_entries(.value |= map(select(.id != "omarchy.system-update"))))' \
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

      xdg.configFile."hypr/input.lua" = {
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
      programs.foot = {
        enable = true;
        settings = {
          main = {
            include = "~/.local/state/omarchy/current/theme/foot.ini";
            shell = "${footTmuxStart}/bin/foot-tmux-start";
            term = "xterm-256color";
            font = "JetBrainsMono Nerd Font:size=9";
            pad = "14x14";
            initial-window-mode = "windowed";
            workers = 0;
          };
          scrollback = {
            lines = 10000;
            multiplier = 7.0;
          };
          cursor = {
            style = "block";
            blink = "no";
          };
          "key-bindings" = {
            clipboard-copy = "Control+Insert Control+Shift+c XF86Copy";
            primary-paste = "none";
            clipboard-paste = "Shift+Insert Control+Shift+v XF86Paste";
          };
          "text-bindings" = {
            "\\x1b[13;2u" = "Shift+Return";
            "\\x1b[13;4u" = "Mod1+Shift+Return";
          };
        };
      };
    })
  ];

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
