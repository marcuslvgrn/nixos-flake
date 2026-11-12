# NixOS flake

Personal NixOS configuration for several physical machines and virtual machines. The flake builds every host under `hosts/` as a `nixosConfigurations` output and shares common system, user, Home Manager, and service modules.

## Quick start

Run these commands from the repository root. Replace `nixosASUS` with the target host name (the directory under `hosts/`).

```sh
# See available configurations
nix flake show

# Format Nix files with the formatter exposed by the flake
nix fmt

# Evaluate/build without activating
sudo nixos-rebuild build --flake .#nixosASUS

# Activate now, or make the configuration the next boot
sudo nixos-rebuild switch --flake .#nixosASUS
sudo nixos-rebuild boot --flake .#nixosASUS

# Update pinned inputs, then review and commit flake.lock
nix flake update
git diff -- flake.lock
```

Home Manager is integrated into each NixOS configuration, so normal system rebuilds also apply the user's Home Manager configuration. The shell aliases `rebuild-switch`, `rebuild-boot`, and `rebuild-build` use `~/git/nixos-flake` and do not specify a host; specify `--flake .#<host>` explicitly when choosing a host. `rebuild-build` runs `nixos-rebuild build` without activating the result.

## Repository layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs, host discovery, channel selection, and `nixosConfigurations` assembly |
| `hosts/<host>/` | Host settings, system configuration, hardware configuration, and optional disk layout |
| `common/configuration.nix` | Shared NixOS defaults, packages, locale, networking, and system services |
| `common/users/` | User account definitions and Home Manager wiring |
| `modules/<name>/` | Reusable, generally option-driven NixOS modules |
| `home-manager/` | Shared user environment and Home Manager modules |
| `overlays/` | Package overlays, including Firefox |
| `lib/packageChannel.nix` | Helper for selecting packages from stable/unstable package sets |

`modules/default.nix` and the Home Manager module loader import immediate subdirectories in sorted order. Add a module as a subdirectory with a `default.nix`; these directories are discovered automatically.

`overlays/php-overlay.nix`, `overlays/technitium-overlay.nix`, and `overlays/airsonic-advanced.nix` are inactive examples showing how to write package overlays. The flake currently applies only `overlays/firefox.nix`; the example overlays have no effect unless explicitly added to the overlay list in `flake.nix`.

## Hosts and settings

Current host directories (and therefore flake host names): `nixosASUS`, `nixosDellXPS`, `nixosG11CD`, `nixosImac`, `nixosImac2017`, `nixosMinimal`, `nixosNUC`, `nixosTranfor`, `nixosTranfor2`, `nixosVBoxGnome`, `nixosVBoxMinimal`, `nixosVMWareGnome`, `nixosVMWareMinimal`, and `nixosX360`.

Every directory in `hosts/` is treated as a host. It must include `configuration.nix` and `hostSettings.nix`, and the latter must define:

```nix
{
  defaultPkgChannel = "stable"; # or "unstable"
  stateVersion = "26.05";       # preserve the host's existing value after install
  # Optional; each defaults to defaultPkgChannel:
  homeManagerChannel = "stable";
  nixvimChannel = "unstable";
  # Optional; defaults to "stable":
  omarchyChannel = "stable";
}
```

`defaultPkgChannel` chooses the main nixpkgs set, and also selects the corresponding NixOS library and kernel policy (unstable hosts use `linuxPackages_latest`). Home Manager and Nixvim can override their channel independently. Both package sets are passed to modules, so an individual module can deliberately choose stable or unstable packages.

`omarchyChannel` selects the Omarchy Nix flake input and defaults to `stable`, independently of `defaultPkgChannel`.

Omarchy's update and package-management commands use `omarchy.nixFlakePath` to find this consumer flake. It defaults to the first configured non-root user's `$HOME/git/nixos-flake`; override it in the host configuration if the checkout is elsewhere. The value may be the flake directory or the path to its `flake.nix` file.

The PXE module builds a separate minimal netboot NixOS configuration. Its `system.stateVersion` is set to `26.05` in `modules/pxe/default.nix`; this belongs to that nested PXE system and is independent of each host's `stateVersion`.

Host directories may contain `hw.nix`, `hardware-configuration.nix`, `disk-config.nix`, and facter data as needed; imports are explicit in that host's configuration. The system platform is currently fixed to `x86_64-linux` in `flake.nix`.

`nginxExternal.proxyHosts` entries enable ACME certificates, HTTPS redirects, and ddclient registration by default. Set `enableACME = false;` or `updateDdclient = false;` on an entry to disable either behavior independently. If disabling ACME without providing another certificate, also set `forceSSL = false;` to serve HTTP without a certificate. `nginxExternal.extraDdclientDomains` adds DDNS-only domains that are not proxy hosts.

## Adding or changing a host

1. Create `hosts/<hostname>/configuration.nix` and `hostSettings.nix`; set a valid `defaultPkgChannel` and the intended `stateVersion`.
2. Add hardware-specific files and import them from the host configuration.
3. Add the host-specific config to version control. Flakes only see tracked files (or files added to Git), so an untracked new host can appear to be missing during evaluation.
4. Evaluate it with `nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath` or build it with `sudo nixos-rebuild build --flake .#<hostname>`.

For a new install, check the host's disk configuration and device paths carefully before running any installer or partitioning command. The shared Disko module uses GPT, an EFI partition mounted at `/efi`, and Btrfs subvolumes for `/`, `/home`, and `/swap`; some hosts instead define their own Disko layout.

Swap files declared through `swapDevices` are created and initialized by NixOS's generated `mkswap-*` services. The legacy `create-swapfile` service is disabled in the shared configuration because running both creators could race on the same file.

## Adding a user

User records are centralized in `common/users/userData.nix`, while each host chooses which accounts to create through its `userNames` option. Adding a record does not enable that account on every host.

1. Add a record under `users` in `common/users/userData.nix`. Use the record key as the account name and keep its `username` field equal to that key. Normal users need `normalUser = true`, a `username`, `email`, and `gituser`; fields such as `group`, `uid`, `extragroups`, `realname`, and `authorizedKeys` provide the corresponding account settings. See the existing `lovgren` and `gerd` entries for examples.
2. Add the user to `userNames` only on hosts where the account should exist. The shared configuration already includes `root` and `lovgren`; a host can add users with `userNames = lib.mkAfter [ "<username>" ];` (or `mkAfter` if `lib` is in scope).
3. For a normal user, add the user's hashed password under `passwords` in `modules/sops/root-secrets.yaml` using `sops modules/sops/root-secrets.yaml`; SOPS encrypts the file when saving. The SOPS module automatically declares `passwords/<username>` with `neededForUsers = true` only on hosts where that normal user is listed in `userNames`. The shared user module reads this secret as `hashedPasswordFile`. Do not put plaintext passwords in Nix files.
4. Optionally create `home-manager/users/<username>.nix` for user-specific Home Manager settings. If that file is absent, the shared Home Manager configuration still applies to the normal user.
5. Evaluate or build each affected host using the commands above. The user module asserts that every host `userNames` entry has a matching record in `userData.nix`.

## Good to know

- `nix flake show` lists generated host outputs. Host names come directly from directories under `hosts/`, rather than a manually maintained list.
- Shared modules are loaded from `modules/`; each module directory is imported automatically. Host hardware files are not automatically loaded: the host's `configuration.nix` must import them.
- `common/configuration.nix` enables NetworkManager and sets DHCP as a default. A host can override DHCP settings in its own configuration or hardware module.
- User names are listed through the shared `userNames` option and their metadata lives in `common/users/userData.nix`. Normal users with a matching `home-manager/users/<name>.nix` get that user file plus the shared Home Manager config.
- Users are immutable (`users.mutableUsers = false`). Password hashes are loaded from SOPS secrets; don't add plaintext credentials to Nix files.
- SOPS uses `modules/sops/root-secrets.yaml` by default and the host SSH Ed25519 key as its age identity. A machine needs the matching SSH host key and encrypted secret data to activate secret-dependent services.
- Shared settings enable automatic Nix garbage collection daily at 20:00, deleting generations older than 14 days. Keep important generations or pin a rollback before relying on long-term local history.
- The shared NixOS module loader imports only immediate subdirectories, sorted alphabetically. Nested modules need to be imported from their parent module.
- Some package modules expose a channel option that defaults to the host's `defaultPkgChannel`; inspect that module before assuming every package comes from the default channel.
- Samba intentionally allows writable guest access to its shares. Clients may connect without credentials and access files as `samba.guestAccount` (default `lovgren`); an unknown username is mapped to guest, while a wrong password for a known username is rejected. The default allowed-host patterns restrict which clients can connect.
- CUPS printer sharing intentionally allows anonymous print jobs from any reachable interface on hosts where `services.printing.enable` is set. The module listens on all interfaces, opens the firewall, shares local printers, and allows all client addresses.
- Kodi's YouTube credentials and IR remote services are scoped to `kodi.users`, which defaults to `[ "lovgren" ]`. Users in that list share the same API credentials and must also be listed in the host's `userNames` option.
- Nextcloud's `nextcloud.initialUsers` option controls accounts created if missing and synchronized at startup. Each entry has a `username`, `displayName`, `email`, and optional `groups`; email and group memberships are kept in sync with the list, and the default list preserves this configuration's current accounts.

### Wakezilla client

The `programs.wakezilla.client` module manages the service and firewall declaratively. Its `port` defaults to `3001`. To configure client authentication, store an environment file as a SOPS secret and reference it from the host:

```nix
{ config, ... }:
{
  sops.secrets."wakezilla-client-env" = { };
  programs.wakezilla.client = {
    enable = true;
    environmentFile = config.sops.secrets."wakezilla-client-env".path;
  };
}
```

The decrypted environment file should contain `WAKEZILLA__SECURITY__CLIENT_SHUTDOWN_KEY=<generated-key>`. Edit it with SOPS; do not put the key directly in a Nix expression, where it would enter the store.

## Command reference

```sh
# Inspect/evaluate
nix flake show
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath

# Build and activate a selected host
sudo nixos-rebuild build --flake .#<host>
sudo nixos-rebuild test --flake .#<host>    # activate until reboot
sudo nixos-rebuild switch --flake .#<host>  # activate now and set as boot default
sudo nixos-rebuild boot --flake .#<host>    # set as boot default only

# Generations and store cleanup
sudo nixos-rebuild list-generations
nix-env --list-generations
sudo nix-collect-garbage --delete-older-than 30d
ncdu /nix

# Inspect Nix store paths
nix-tree
```

The flake exposes a pinned `nixos-anywhere` app for x86_64 Linux, available as `nix run .#nixos-anywhere`. `scripts/install.sh` wraps it for remote installs and handles registering the target machine's SSH host key as a SOPS recipient first.

```sh
# From the expected checkout at "$HOME/git/nixos-flake"
sudo scripts/install.sh -i <target-ip> -h <flake-host>

# Skip the Disko phase, or build the installer configuration on the target
sudo scripts/install.sh -i <target-ip> -h <flake-host> -d no
sudo scripts/install.sh -i <target-ip> -h <flake-host> -b remote
```

The target must already be reachable as `root` over SSH and have an Ed25519 SSH host key. The script adds that key's age identity to `.sops.yaml`, runs `sops updatekeys` on `modules/sops/root-secrets.yaml`, then invokes the flake-pinned nixos-anywhere app. The source machine needs Nix and the repository's required tools (`ssh`, `ssh-to-age`, `sops`, and `sudo`); `-d yes` is the default and runs Disko; review the host's disk device/layout before using it because partitioning can erase data. `-d no` skips only the Disko phase. The script expects the checkout at `$HOME/git/nixos-flake` and copies `$HOME/git` into the install's extra files.

## Neovim shortcuts

The shared Nixvim config enables Neo-tree and Telescope. The leader key is Space; Neo-tree opens at startup. Telescope provides `<leader>ff` (find files) and `<leader>fb` (buffers). Neo-tree shows hidden files. Window navigation uses `Ctrl-w` followed by `h`, `j`, `k`, or `l`; `Ctrl-w w` cycles windows. `Ctrl-o` and `Ctrl-i` move backward and forward through the jump list, and `gf` opens the file under the cursor when it can resolve the path.

## Other useful notes

Generate a Nix fetcher from a release URL with `nurl <url>`. For example:

```sh
nurl https://github.com/airsonic-advanced/airsonic-advanced/releases/download/11.0.0-SNAPSHOT.20240424015024/airsonic.war
```

MariaDB backups:

```sh
sudo mariadb-dump --all-databases | gzip > mariadb-full.sql.gz
sudo gunzip -c mariadb-full.sql.gz | sudo mysql

sudo -u nextcloud mariadb-dump nextcloud | gzip > mariadb-nextcloud.sql.gz
sudo -u nextcloud gunzip -c mariadb-nextcloud.sql.gz | mariadb nextcloud
```

## Reference links

- [NixOS package search](https://search.nixos.org/packages) · [NixOS options](https://search.nixos.org/options) · [Home Manager options](https://home-manager-options.extranix.com/)
- [Nix reference manual](https://nix.dev/reference/nix-manual.html) · [NixOS manual](https://nixos.org/manual/nixos/stable/) · [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/)
- [NUR](https://github.com/nix-community/NUR) · [SOPS-Nix](https://github.com/Mic92/sops-nix) · [Disko](https://github.com/nix-community/disko) · [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
