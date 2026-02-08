# My nixos-flake for multiple hosts
This is a flake that loads configurations for many hosts.

## Links
### Searches
- [NixOS Package Search](https://search.nixos.org/packages)
- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Search](https://home-manager-options.extranix.com/)
### Manuals
- [Nix reference manual - nix.dev](https://nix.dev/reference/nix-manual.html)
- [Nix Manual](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
### Community
- [nix.dev](https://nix.dev/)
- [NUR](https://github.com/nix-community/NUR)
  - [NUR collection of firefox extensions](https://nur.nix-community.org/repos/rycee/)
- [Nix cookbook](https://wiki.nixos.org/wiki/Nix_Cookbook)
- [Official Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki)
- [User Wiki](https://nixos.wiki/)

## Cheatsheet
List all NixOS generations
```sh
$ nix-env --list-generations
```

garbage collect, delete all generations of profiles older than the specified amount (except for the generations that were active at that point in time). period is a value such as 30d, which would mean 30 days.
```
$nix-collect-garbage --delete-older-than <period>
```

Use nurl to generate fetcher
```sh
$ nurl https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war
fetchFromGitHub {
  owner = "airsonic-advanced";
  repo = "airsonic-advanced";
  rev = "68d11bfbfe051b0acaca2770c3c1f47f8d59201c";
  hash = "sha256-QC2UHUHvXUdvs3Q0X4o+pbFdwKQ1W+zQBmp8vIqrsAE=";
}
```
dump mariadb databases
```sh
sudo mariadb-dump --all-databases | gzip > mariadb-full.sql.gz
```

restore later with
```sh
sudo gunzip -c mariadb-full.sql.gz | sudo mysql
```

for single databases
```sh
sudo -u nextcloud mariadb-dump nextcloud | gzip > mariadb-nextcloud.sql.gz
```

restore later with
```sh
sudo -u nextcloud gunzip -c mariadb-nextcloud.sql.gz | mariadb nextcloud
```


## Packages I use (or intend to use)
- [technitium dns server](https://technitium.com/) on github https://github.com/TechnitiumSoftware/DnsServer
- [airsonic advanced music streaming](https://docs.linuxserver.io/images/docker-airsonic-advanced), on github https://github.com/airsonic-advanced/airsonic-advanced
- [Nextcloud, your own cloud](https://nextcloud.com/) on github https://github.com/nextcloud
  - [Nextcloud backup](https://github.com/nextcloud/backup)
- [Bitwarden password manager](https://bitwarden.com), vaultwarden on github [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
- [sops-nix secrets management](https://github.com/Mic92/sops-nix)
- [disko - Declarative disk partitioning](https://github.com/nix-community/disko)
- [nixos-anywhere, install NixOS everywhere via ssh](https://github.com/nix-community/nixos-anywhere)
- [nix-darwin, use nix on macOS](https://github.com/nix-darwin/nix-darwin)
- [nix-flatpak, flatpak manager fir NixOS](https://github.com/gmodena/nix-flatpak)
- [flake-utils](https://github.com/numtide/flake-utils)
- [nixos-facter](https://github.com/nix-community/nixos-facter)

## My aliases
- gs = git status
- gpl = git pull
- ga = git add
- gc = git commit
- gpl = git pull
- gps = git push
- rebuild = rebuild flake

## neovim shortcuts
- gf = go to file referenced by code
- ctrl+o = go back to previous buffer
- ctrl+i = go forward to next buffer
- lead+ff = telescope find_files
- lead+fb = telescope buffers
- ctrl+w h = move to left window
- ctrl+w l = move to right window
- ctrl+w j = move to window below
- ctrl+w k = move to window above
- ctrl+w w = cycle through windows
