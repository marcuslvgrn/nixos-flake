#!/usr/bin/env bash

set -e

root_device="/dev/sda2"
efi_device="/dev/sda1"

usage() {
    echo "Usage: $0 [-r <root-device>] [-e <efi-device>] <host>"
    echo
    echo "Options:"
    echo "  -r <device>   Root device (default: /dev/sda2)"
    echo "  -e <device>   EFI device  (default: /dev/sda1)"
    exit 1
}

while getopts "r:e:" opt; do
    case "$opt" in
        r)
            root_device="$OPTARG"
            ;;
        e)
            efi_device="$OPTARG"
            ;;
        \?)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
    usage
fi

host="$1"

echo "Host:        $host"
echo "Root device: $root_device"
echo "EFI device:  $efi_device"

ssh "root@$host" <<EOF
set -e

mount "$root_device" /mnt -o subvol=@
mount "$root_device" /mnt/home -o subvol=@home
mount "$efi_device" /mnt/efi

echo "Filesystem mounted successfully."
EOF
