{
  config,
  inputs,
  lib,
  pkgs,
  hostSettings,
  ...
}:
let
  cfg = config.omarchy;
  omarchyInput =
    if hostSettings.omarchyChannel == "stable" then
      inputs.omarchy-nix-stable
    else
      inputs.omarchy-nix-unstable;
in
{
  imports = [ omarchyInput.nixosModules.default ];

  options.omarchy.nixFlakePath = lib.mkOption {
    type = lib.types.str;
    default = "${config.users.homeBaseDir or "/home"}/${
      builtins.head (lib.filter (username: username != "root") config.userNames)
    }/git/nixos-flake";
    description = "Path to this consumer flake for Omarchy's NixOS package and update commands.";
  };

  config = lib.mkMerge [
    {
      # Home Manager applies sharedModules to each configured user. Keep this
      # unconditional so the user's omarchy option is declared on every host.
      home-manager.sharedModules = [ omarchyInput.homeModules.default ];
    }
    (lib.mkIf cfg.enable {
      # Omarchy's graphical-session units otherwise also start in GNOME.
      # Keep them available in a Hyprland/Omarchy session, but skip them in
      # other desktop sessions.
      systemd.user.services =
        lib.genAttrs
          [
            "bt-agent"
            "omarchy-fcitx5"
            "omarchy-migrate-notify"
            "omarchy-migrate"
            "omarchy-sleep-lock"
            "omarchy-recover-internal-monitor"
            "omarchy-crash-watch"
            "owed"
            "omarchy-tailscale-receive"
          ]
          (_: {
            unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
          })
        // {
          "app-ibus\\x2ddaemon@autostart".enable = false;
        };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      # Quickshell is pinned to Qt 6.11 while the system Qt is newer. Put its
      # matching image plugins first so it can decode Omarchy's WebP wallpapers.
      environment.sessionVariables.QT_PLUGIN_PATH = lib.mkForce (
        "${
          inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.qt6.qtimageformats
        }/lib/qt-6/plugins:${config.system.path}/lib/qt-6/plugins"
      );

      # IBus' generic desktop-file autostart launches its daemon outside the
      # compositor's Wayland input-method setup and raises a warning on Omarchy.
      # Omarchy does not use IBus as its Wayland input method.
      # Use the upstream Omarchy desktop shell, bar, shortcuts, and menu here.
      omarchy = {
        sddm.theme = false;
        theme = "tokyo-night";
        #exclude_packages = [
        #  "owe"
        #];
      };
      # Keep GNOME's GDM as the sole display manager; the Omarchy shell does not
      # depend on SDDM or its greeter theme.
      services.displayManager.sddm.enable = lib.mkForce false;
      # GNOME and Omarchy provide different Nautilus extension paths. Follow
      # GNOME's store-backed path so its extensions remain discoverable.
      environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = lib.mkForce (
        "${config.system.path}/lib/nautilus/extensions-4"
      );
      environment.sessionVariables.OMARCHY_NIX_FLAKE = cfg.nixFlakePath;

      # Some laptop displays return from suspend in a valid but incorrect mode.
      # Reload each active Hyprland instance after resume so its explicit
      # monitors.lua mode is applied again. Other desktop sessions have no
      # Hyprland socket and are left alone.
      powerManagement.resumeCommands = ''
        sleep 1
        ${pkgs.findutils}/bin/find /run/user -type s -path '*/hypr/*/.socket.sock' -print0 2>/dev/null |
          while IFS= read -r -d $'\0' socket; do
            instance_dir="''${socket%/.socket.sock}"
            instance="''${instance_dir##*/}"
            runtime_dir="''${instance_dir%/hypr/*}"
            uid="''${runtime_dir##*/}"
            username="$(${pkgs.coreutils}/bin/id -nu "$uid" 2>/dev/null)" || continue

            if XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE="$instance" \
              ${pkgs.util-linux}/bin/runuser --preserve-environment -u "$username" -- \
              ${config.programs.hyprland.package}/bin/hyprctl reload; then
              ${pkgs.util-linux}/bin/logger -t omarchy-monitor-resume \
                "Reloaded Hyprland monitor configuration for $username ($instance)"
            else
              ${pkgs.util-linux}/bin/logger -t omarchy-monitor-resume \
                "Failed to reload Hyprland monitor configuration for $username ($instance)"
            fi
          done
      '';

      # The upstream lock PAM file is hand-written and uses the unqualified
      # pam_fprintd.so name. NixOS resolves that under linux-pam, but the module
      # is shipped by fprintd (or fprintd-tod on this host).
      security.pam.services.omarchy-lock-fingerprint.text = lib.mkIf cfg.fingerprint.enable (
        lib.mkForce ''
          #%PAM-1.0
          auth       required                    ${config.services.fprintd.package}/lib/security/pam_fprintd.so
          account    required                    pam_unix.so
        ''
      );

      programs.tmux.enable = true;
    })
  ];
}
