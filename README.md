# My nixos-flake for multiple hosts
This is a flake that loads configurations for many hosts.

## Links
- [NixOS Package search](https://search.nixos.org/packages)
- [NixOS Options search](https://search.nixos.org/options)
- [NUR](https://github.com/nix-community/NUR)
  - [NUR collection of firefox extensions](https://nur.nix-community.org/repos/rycee/)

## Cheatsheet
Use nurl to generate fetcher
```sh
nurl https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war
fetchFromGitHub {
  owner = "airsonic-advanced";
  repo = "airsonic-advanced";
  rev = "68d11bfbfe051b0acaca2770c3c1f47f8d59201c";
  hash = "sha256-QC2UHUHvXUdvs3Q0X4o+pbFdwKQ1W+zQBmp8vIqrsAE=";
}
```

## Aliases
- gs = git status
- gpl = git pull
- ga = git add
- gc = git commit
- gpl = git pull
- gps = git push
- rebuild = rebuild flake
