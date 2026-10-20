{
  #  config,
  # lib,
  #  inputs,
  # nixosConfig,
  # userConfig,
  pkgs,
  #  pkgs-stable,
  # pkgs-unstable,
  ...
}:

{
  config = {
    home.shellAliases = {
      nixos-generations-delete = "nix-env -p /nix/var/nix/profiles/system --delete-generations ";
    };
    home.packages = [
      (pkgs.writeShellScriptBin "nixos-generations-list" ''
        #!/usr/bin/env bash
        if [ -n "$SUDO_USER" ]; then
          user_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
        else
          user_home="$HOME"
        fi

        flake="$user_home/git/nixos-flake"

        printf '%-4s %-19s %-12s %-2s %s\n' \
          "GEN" "DATE" "REVISION" "" "COMMIT MESSAGE"
        printf '%-4s %-19s %-12s %-2s %s\n' \
          "----" "-------------------" "------------" "--" "------------------------------"

        sudo nixos-rebuild list-generations |
        while read -r gen date time rest; do
          [[ "$gen" =~ ^[0-9]+ ]] || continue

          revision="$(printf '%s\n' "$rest" | grep -oE '[0-9a-f]{40}(-dirty)?' | head -1)"

          if [[ "$revision" == *-dirty ]]; then
            dirty="D"
            revision="''${revision%-dirty}"
          else
            dirty=""
          fi

          short="''${revision:0:12}"

          message="$(
            git -C "$flake" log -1 --format='%s' "$revision" 2>/dev/null ||
            printf '%s' "-"
          )"

          printf '%-4s %-19s %-12s %-2s %s\n' \
            "$gen" "$date $time" "$short" "$dirty" "$message"
        done
        nixos-generations-type
      '')

      (pkgs.writeShellScriptBin "nixos-generations-delete-dirty" ''
        #!/usr/bin/env bash

        set -u

        profile="/nix/var/nix/profiles/system"

        # Resolve the original user's home directory, including under sudo.
        if [ -n "''${SUDO_USER:-}" ]; then
          user_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
        else
          user_home="$HOME"
        fi

        # Identify the current generation so it is never deleted.
        current="$(readlink "$profile")"
        current="''${current#system-}"
        current="''${current%-link}"

        echo "Current generation: $current"
        echo

        # List generations; request elevation only when needed.
        if [ "$EUID" -eq 0 ]; then
          nixos-rebuild list-generations
        else
          sudo nixos-rebuild list-generations
        fi |
        while read -r gen date time rest; do
          [[ "$gen" =~ ^[0-9]+$ ]] || continue

          # Never delete the current generation.
          [[ "$gen" == "$current" ]] && continue

          # Only consider generations marked dirty.
          [[ "$rest" == *-dirty* ]] || continue

          echo "Dirty generation: $gen ($date $time)"
          read -r -p "Delete generation $gen? [y/N] " answer </dev/tty

          if [[ "$answer" =~ ^[Yy]$ ]]; then
            echo "Deleting generation $gen..."

            if [ "$EUID" -eq 0 ]; then
              nix-env \
                --profile "$profile" \
                --delete-generations "$gen"
            else
              sudo nix-env \
                --profile "$profile" \
                --delete-generations "$gen"
            fi
          else
            echo "Keeping generation $gen."
          fi

          echo
        done
      '')
      (pkgs.writeShellScriptBin "nixos-generations-type" ''
        #!/usr/bin/env bash

        current=$(readlink -f /run/current-system)
        booted=$(readlink -f /run/booted-system)
        default=$(readlink -f /nix/var/nix/profiles/system)
        booted_found=false

        for link in /nix/var/nix/profiles/system-*-link; do
          [ -e "$link" ] || continue
          [ "$(readlink -f "$link")" = "$booted" ] && booted_found=true
        done

        for link in /nix/var/nix/profiles/system-*-link; do
          [ -e "$link" ] || continue
          target=$(readlink -f "$link")
          gen=''${link##*system-}
          gen=''${gen%-link}

          markers=""
          [ "$target" = "$current" ] && markers+=" CURRENT"
          [ "$target" = "$booted" ] && markers+=" BOOTED"
          [ "$target" = "$default" ] && markers+=" DEFAULT"

          [ -n "$markers" ] || continue
          printf "%-6s %s%s\n" "$gen" "$(stat -c '%y' "$link" | cut -d. -f1)" "$markers"
        done | sort -n

        [ "$booted_found" = true ] || echo "BOOTED has been removed"
      '')
    ];
  };

}
