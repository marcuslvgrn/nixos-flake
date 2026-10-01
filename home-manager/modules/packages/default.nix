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
    home = {
      packages = [
        (pkgs.writeShellScriptBin "nixos-generations" ''
          #!/usr/bin/env bash

          flake="$HOME/git/nixos-flake"

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
        '')
      ];
    };
  };

}
