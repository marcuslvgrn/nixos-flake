#!/usr/bin/env bash

set -e

ipnumber=""
host=""
disko="yes"
build="local"

usage() {
    echo "Usage: $0 -i <IP> -h <host> [-d <yes|no>]"
    echo
    echo "Options:"
    echo "  -i <IP>       IP address of target host"
    echo "  -h <host>     NixOS host name from flake"
    echo "  -d <yes|no>   Run disko phase (default: yes)"
    echo "  -b <local|remote> Build local or remote (default: local)"
    exit 1
}

while getopts "i:h:d:b:" opt; do
    case "$opt" in
        i)
            ipnumber="$OPTARG"
            ;;
        h)
            host="$OPTARG"
            ;;
        d)
            disko="$OPTARG"
            ;;
        b)
            build="$OPTARG"
            ;;
        \?)
            usage
            ;;
    esac
done

# Check required arguments
if [[ -z "$ipnumber" || -z "$host" ]]; then
    echo "Error: -i and -h are required."
    usage
fi

# Check disko value
if [[ "$disko" != "yes" && "$disko" != "no" ]]; then
    echo "Error: -d must be 'yes' or 'no'."
    exit 1
fi

# Check build value
if [[ "$build" != "local" && "$build" != "remote" ]]; then
    echo "Error: -b must be 'local' or 'remote'."
    exit 1
fi
if [[ ! "$host" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]]; then
    echo "Error: host name must contain only letters, numbers, '_' or '-'."
    exit 1
fi

cd /home/lovgren/git/nixos-flake
repo_owner=${SUDO_USER:-$(id -un)}
repo_group=$(id -gn "$repo_owner")

# Register the target's existing SSH host key as a SOPS recipient before
# installing. nixos-anywhere's --copy-host-keys then preserves the matching
# private key in the installed system for the first SOPS activation.
echo "Reading SSH host key from root@$ipnumber..."
if ! host_public_key=$(ssh "root@$ipnumber" \
    'test -s /etc/ssh/ssh_host_ed25519_key && cat /etc/ssh/ssh_host_ed25519_key.pub'); then
    echo "Error: target must be reachable as root and have an Ed25519 host key."
    exit 1
fi
if [[ -z "$host_public_key" ]]; then
    echo "Error: target did not provide an Ed25519 SSH host public key."
    exit 1
fi

age_recipient=$(printf '%s\n' "$host_public_key" | ssh-to-age)
if [[ ! "$age_recipient" =~ ^age1[[:alnum:]]+$ ]]; then
    echo "Error: could not convert the target host key to an age recipient."
    exit 1
fi

echo "Registering SOPS recipient for $host ($age_recipient)..."
recipient_config=$(mktemp .sops.yaml.XXXXXX)
if ! awk -v host="$host" -v recipient="$age_recipient" \
    -f scripts/install/register-sops-host.awk .sops.yaml > "$recipient_config"; then
    rm -f "$recipient_config"
    exit 1
fi
if cmp -s .sops.yaml "$recipient_config"; then
    echo "SOPS recipient is already registered."
    rm -f "$recipient_config"
else
    chmod --reference=.sops.yaml "$recipient_config"
    mv "$recipient_config" .sops.yaml
fi
sudo sops updatekeys -y modules/sops/root-secrets.yaml

# Keep the checkout editable by its regular owner when this script is run via sudo.
if [[ "$EUID" -eq 0 ]]; then
    chown "$repo_owner:$repo_group" .sops.yaml modules/sops/root-secrets.yaml
else
    sudo chown "$repo_owner:$repo_group" .sops.yaml modules/sops/root-secrets.yaml
fi

# Build phases
phases="kexec,install,reboot"

if [[ "$disko" == "yes" ]]; then
    phases="kexec,disko,install,reboot"
fi

echo "IP:     $ipnumber"
echo "Host:   $host"
echo "Disko:  $disko"
echo "Phases: $phases"
echo "Build:  $build"

# Create a temporary directory
temp=$(mktemp -d)

cleanup() {
    rm -rf "$temp"
}
trap cleanup EXIT

# Git repos
install -d -m755 "$temp/home/lovgren/git"
cp -r /home/lovgren/git/* "$temp/home/lovgren/git/"

# Install NixOS using the pinned nixos-anywhere from the flake
sudo nix run path:/home/lovgren/git/nixos-flake#nixos-anywhere -- \
    --copy-host-keys \
    --extra-files "$temp" \
    --phases "$phases" \
    --chown /home/lovgren/git 1000:100 \
    --flake "path:/home/lovgren/git/nixos-flake#$host" \
    --target-host "root@$ipnumber" \
    --build-on "$build"
