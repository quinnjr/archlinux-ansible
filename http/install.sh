#!/bin/bash

set -e
set -x

mountpoint=/mnt

if [ -e /dev/vda ]; then
  vhd=/dev/vda
elif [ -e /dev/sda ]; then
  vhd=/dev/sda
else
  echo "ERROR: Failed to find a virtual harddrive for installation." >&2
  exit 1
fi
export vhd

swap_size=$(($(free | awk '/^Mem:/ { print $2 }') * 2))

sfdisk "$vhd" <<EOF
label: dos
size=${swap_size}KiB, type=82
  type=83, bootable
EOF

swap_part="${vhd}1"
root_part="${vhd}2"

mkswap "${swap_part}"
swapon "${swap_part}"
mkfs.btrfs -L "arch_root" "${root_part}"
mount "${root_part}" "${mountpoint}"

pacstrap "${mountpoint}" base base-devel grub openssh \
  sudo polkit btrfs-progs ansible

genfstab -p -U /mnt >> /mnt/etc/fstab

arch-chroot "${mountpoint}" /bin/bash
