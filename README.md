# My nixos-flake for multiple hosts
This is a flake that loads configurations for many hosts.

# Cheatsheet
Use nurl to generate fetcher
```nix
nurl https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war
$ nix flake prefetch --extra-experimental-features 'nix-command flakes' --json github:airsonic-advanced/airsonic-advanced/68d11bfbfe051b0acaca2770c3c1f47f8d59201c
warning: Pathname can't be converted from UTF-8 to current locale.
warning: Pathname can't be converted from UTF-8 to current locale.
fetchFromGitHub {
  owner = "airsonic-advanced";
  repo = "airsonic-advanced";
  rev = "68d11bfbfe051b0acaca2770c3c1f47f8d59201c";
  hash = "sha256-QC2UHUHvXUdvs3Q0X4o+pbFdwKQ1W+zQBmp8vIqrsAE=";
}
```
