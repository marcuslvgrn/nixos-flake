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

# AGE key
install -d -m755 "$temp/root/.config/sops/age"
sudo cp /run/secrets/age/keys.txt \
    "$temp/root/.config/sops/age/keys.txt"

# SSH keys
install -d -m755 "$temp/etc/ssh/authorized_keys.d"
sudo cp -r /run/secrets/ssh/authorized_keys/root \
    "$temp/etc/ssh/authorized_keys.d/"

install -d -m755 "$temp/home/lovgren/.ssh"
sudo cp /run/secrets/ssh/authorized_keys/lovgren \
    "$temp/home/lovgren/.ssh/authorized_keys"

sudo cp /run/secrets/ssh/keys/id_ed25519 \
    "$temp/home/lovgren/.ssh/"
sudo cp /run/secrets/ssh/keys/id_ed25519.pub \
    "$temp/home/lovgren/.ssh/"

# Git repos
install -d -m755 "$temp/home/lovgren/git"
cp -r /home/lovgren/git/* "$temp/home/lovgren/git/"

# Install NixOS
sudo nix run github:nix-community/nixos-anywhere -- \
    --copy-host-keys \
    --extra-files "$temp" \
    --phases "$phases" \
    --chown /home/lovgren/.ssh 1000:100 \
    --chown /home/lovgren/git 1000:100 \
    --chown /root/.config/sops 0:0 \
    --flake "/home/lovgren/git/nixos-flake#$host" \
    --target-host "root@$ipnumber" \
    --build-on "$build"
