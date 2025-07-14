#!/usr/bin/env bash
#connect through ssh
#passwd
#ip a

read -p "Type the IP number to install to: " ipnumber
read -p "Type the host to install: " host

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

#copy stuff
install -d -m755 "$temp/root/.config"
cp -r /root/.config/sops  "$temp/root/.config/"
install -d -m755 "$temp/etc/ssh/authorized_keys.d"
cp -r /run/secrets/ssh/authorized_keys/root "$temp/etc/ssh/authorized_keys.d/"
install -d -m755 "$temp/home/lovgren"
cp -r /home/lovgren/git $temp/home/lovgren
#git clone git@github.com:marcuslvgrn/nixos-flake $temp/home/lovgren/git
#git clone git@github.com:marcuslvgrn/nixos-dotfiles $temp/home/lovgren/git

#cp -r /home/lovgren/git $temp/home/lovgren/
install -d -m755 "$temp/home/lovgren/.ssh"
cp /home/lovgren/.ssh/id_ed25519.pub "$temp/home/lovgren/.ssh/authorized_keys"

# Install NixOS to the host system with our secrets
nix run github:nix-community/nixos-anywhere -- --copy-host-keys --extra-files $temp \
    --phases kexec,disko,install \
    --chown /home/lovgren/git 1000:100 \
    --chown /home/lovgren/.ssh 1000:100 \
    --flake .#$host \
    --target-host root@$ipnumber

#reboot
#nix run github:nix-community/nixos-anywhere -- --copy-host-keys --extra-files $temp --flake .#nixosMinimal --target-host root@192.168.0.195

echo "You must now set the root and user passwords manually by executing \`nixos-enter --root /mnt\` and then running \`passwd\` in the shell of the new system."
read -p "Press Enter to continue"
echo "Also, run stow by /home/lovgren/git/nixos-dotfiles/apply-dotfiles.sh"
read -p "Press Enter to continue"
