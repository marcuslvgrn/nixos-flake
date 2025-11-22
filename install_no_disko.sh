#!/usr/bin/env bash
#connect through ssh
#passwd
#ip a

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
install -d -m755 "$temp/root/.config/sops/age"
$(sudo cp /run/secrets/age/keys.txt "$temp/root/.config/sops/age/keys.txt")

#SSH keys
#authorized keys, for root
install -d -m755 "$temp/etc/ssh/authorized_keys.d"
$(sudo cp -r /run/secrets/ssh/authorized_keys/root "$temp/etc/ssh/authorized_keys.d/")
#authorized keys, for lovgren
install -d -m755 "$temp/home/lovgren/.ssh"
#copy the authorized keys from installation host
$(sudo cp /run/secrets/ssh/authorized_keys/lovgren "$temp/home/lovgren/.ssh/authorized_keys")
#ssh keys for target host, from sops
$(sudo cp /run/secrets/ssh/keys/id_ed25519 "$temp/home/lovgren/.ssh/")
$(sudo cp /run/secrets/ssh/keys/id_ed25519.pub "$temp/home/lovgren/.ssh/")

#git repos
install -d m755 "$temp/home/lovgren/git"
cp -r /home/lovgren/git/* "$temp/home/lovgren/git/"

# Install NixOS to the host system with our secrets
#$(sudo nix run github:nix-community/nixos-anywhere -- --copy-host-keys --extra-files $temp --build-on-remote --phases kexec,install,reboot --chown /home/lovgren/.ssh 1000:100 --chown /home/lovgren/git 1000:100 --chown /root/.config/sops 0:0 --flake /home/lovgren/git/nixos-flake#$host --target-host root@$ipnumber)
sudo nix run github:nix-community/nixos-anywhere -- --copy-host-keys --extra-files $temp --phases kexec,install,reboot --chown /home/lovgren/.ssh 1000:100 --chown /home/lovgren/git 1000:100 --chown /root/.config/sops 0:0 --flake /home/lovgren/git/nixos-flake#$host --target-host root@$ipnumber

echo "Run stow by \`/home/lovgren/git/nixos-dotfiles/apply-dotfiles.sh\`"
read -p "Press Enter to continue"
echo "run \`sudo nixos-rebuild --flake . switch\` in the nixos-flake directory"
read -p "Press Enter to continue"
echo "All done"
