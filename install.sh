#sudo -i
#
#loadkeys sv-latin1
#
##mount drives
#gdisk /dev/sda
##EFI system partition, type is 0xef00
#mkfs.fat -F 32 /dev/sda1
#mkfs.btrfs /dev/sda2
#mount /dev/sda2 /mnt
#cd /mnt
#btrfs subv create @
#btrfs subv create @home
#cd ..
#umount /mnt
#mount /dev/sda2 /mnt -o subvol=@
#mkdir /mnt/home
#mount /dev/sda2 /mnt/home -o subvol=@home
#mkdir /mnt/efi
#mount /dev/sda1 /mnt/efi
#cd /mnt
#btrfs subv create swap
#chattr +C /mnt/swap
#btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile
#exit
##drives mounted

#connect through ssh
passwd
ip a
# ssh to ip from install host terminal
# connected through ssh

#generate hardware config on target
#nixos-generate-config --root /mnt --dir nixos-flake/hosts/nixosMinimal
#then copy to host

#parition and install using nixos-anywhere
nix run github:nix-community/nixos-anywhere -- --flake .#<host> --target-host root@<ip address>
#nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hosts/nixosMinimal/hardware-configuration.nix --flake .#nixosMinial --target-host root@<ip address>
#clone flake repo
ssh-keygen
#add key to github settings
cat .ssh/id_ed25519.pub
git clone git@github.com:marcuslvgrn/nixos-flake
git clone git@github.com:marcuslvgrn/nixos-dotfiles
nixos-dotfiles/apply-dotfiles.sh
sudo nixos-rebuild --flake . switch
