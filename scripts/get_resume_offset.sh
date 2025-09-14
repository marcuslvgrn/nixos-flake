#!/usr/bin/env bash

tmp_dir="$(mktemp -d)"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
btrfs_map_physical="$tmp_dir/btrfs_map_physical"
gcc -O2 -o "$btrfs_map_physical" $SCRIPT_DIR/../code/btrfs_map_physical.c
physical_offset="$(sudo "$btrfs_map_physical" /swap/swapfile | cut -f9 | head -n2 | tail -n1)"
pagesize="$(getconf PAGESIZE)"
resume_offset=$((physical_offset / pagesize))
rm -r "$tmp_dir"
echo "resume_offset=$resume_offset"
