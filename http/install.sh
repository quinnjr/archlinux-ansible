#!/bin/bash -eux

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: Failed to find a virtual harddrive for installation." >&2
  exit 1
fi
export device

swap_size=$(($(free | awk '/^Mem:/ { print $2 }') * 2))

sfdisk "$device" <<EOF
label: dos
size=${swap_size}KiB, type=82
  type=83, bootable
EOF

mkswap "${device}1"
swapon "${device}1"

mkfs.btrfs -L "arch_root" "${device}2"
mount "${device}2" /mnt

printf "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist

curl -fsS https://www.archlinux.org/mirrorlist/?country=all > /tmp/mirrolist
grep '^#Server' /tmp/mirrolist | grep "https" | sort -R | head -n 5 | sed 's/^#//' >>  /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux grub openssh \
  sudo polkit btrfs-progs ansible dhcpcd mkinitcpio vim

genfstab -p -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash
[ -f /mnt/etc/fstab.pacnew ] && rm -f /mnt/etc/fstab.pacnew
swapoff "${device}1"
