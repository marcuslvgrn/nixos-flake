#!/usr/bin/env bash
#connect through ssh
#passwd
#ip a

echo "This script must be run as root."
read -p "Press Enter to continue"

read -p "Type the IP number to install to: " ipnumber
read -p "Type the host type to install: " host

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

#copy stuff into --extra-files

#AGE key
install -d -m755 "$temp/root/.config/sops/age/age.key"
cp /run/secrets/age/keys/$host/age.key "$temp/root/.config/sops/age/age.key"

#SSH keys
#authorized keys, for root
install -d -m755 "$temp/etc/ssh/authorized_keys.d"
cp -r /run/secrets/ssh/authorized_keys/root "$temp/etc/ssh/authorized_keys.d/"
#authorized keys, for lovgren
install -d -m755 "$temp/home/lovgren/.ssh"
#copy the key from installation host
cp /home/lovgren/.ssh/id_ed25519.pub "$temp/home/lovgren/.ssh/authorized_keys"
#ssh keys for target host, from sops
cp /run/secrets/ssh/keys/$host/id_ed25519 "$temp/home/lovgren/.ssh/"
cp /run/secrets/ssh/keys/$host/id_ed25519.pub "$temp/home/lovgren/.ssh/"

# Install NixOS to the host system with our secrets
nix run github:nix-community/nixos-anywhere -- \
    --copy-host-keys \
    --extra-files $temp \
    --phases kexec,disko,install \
    --chown /home/lovgren/git 1000:100 \
    --chown /home/lovgren/.ssh 1000:100 \
    --flake /home/lovgren/git/nixos-flake#$host \
    --target-host root@$ipnumber

#nix run github:nix-community/nixos-anywhere -- --copy-host-keys --extra-files $temp --flake .#nixosMinimal --target-host root@192.168.0.195

echo "Run \`nixos-enter --root /mnt\`to enter the new system"
read -p "Press Enter to continue"
echo "Set the root and user passwords manually by executing  and then running \`passwd\` in the shell of the new system."
read -p "Press Enter to continue"
echo "Now reboot host"
read -p "Press Enter to continue"
echo "Run \`git clone git@github.com:marcuslvgrn/nixos-flake /home/lovgren/git/nixos-flake\` and \`git clone git@github.com:marcuslvgrn/nixos-dotfiles /home/lovgren/git/nixos-dotfiles\`"
read -p "Press Enter to continue"
echo "Run stow by \`/home/lovgren/git/nixos-dotfiles/apply-dotfiles.sh\`"
read -p "Press Enter to continue"
echo "run \`sudo nixos-rebuild --flake . switch\` in the nixos-flake directory"
read -p "Press Enter to continue"
echo "All done"
