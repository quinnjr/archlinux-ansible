#!/usr/bin/env bash
set -eu

DISK='/dev/sda'

CONFIGSCRIPT='/tmp/arch-config.sh'
BOOTPART="${DISK}2"
ROOTPART="${DISK}3"
MNTDIR='/mnt'
COUNTRY=${COUNTRY:-US}
MIRRORLIST="https://www.archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=https&ip_version=4&use_mirror_status=on"

echo '===> Creating local pacman proxy'
echo 'Server = http://10.0.2.2:8899/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# echo '===> Updating pacman mirrorlist'
# curl -s "$MIRRORLIST" | sed 's/^#Server/Server/' > /etc/pacman.d/mirrorlist

echo "===> Zapping ${DISK}"
/usr/bin/sgdisk --zap ${DISK}

echo "===> Zeroing ${DISK}"
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo "===> Partitioning ${DISK}"
/usr/bin/sgdisk --new=1:2048:4095 -t 1:ef02 ${DISK}
/usr/bin/sgdisk --new=2:4096:+200M -t 2:8300 ${DISK}
/usr/bin/sgdisk --new=3:0:0 -t 3:8304 ${DISK}

echo "===> Setting boot flag"
/usr/bin/sgdisk --attributes=1:ef02:1

echo "===> Making filesystems on ${ROOTPART}, ${BOOTPART}"
/usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L root ${ROOTPART}
/usr/bin/mkfs.ext4 -F -m 0 -q -L boot ${BOOTPART}

echo '===> Mounting root partition'
/usr/bin/mount -o noatime,errors=remount-ro ${ROOTPART} ${MNTDIR}

echo '===> Making boot directory'
/usr/bin/mkdir -p "${MNTDIR}/boot"

echo '===> Mounting boot partition'
/usr/bin/mount -o noatime,errors=remount-ro ${BOOTPART} "${MNTDIR}/boot"

echo '===> Installing base and base-devel groups'
/usr/bin/pacstrap ${MNTDIR} base base-devel openssh grub ansible python python2 python-ansible

echo '===> Generating fstab'
/usr/bin/genfstab -p ${MNTDIR} >> "${MNTDIR}/etc/fstab"

echo '===> Configuring the base system'
install -Dm0755 /root/post-base.sh ${MNTDIR}/usr/local/bin/post-base.sh

/usr/bin/arch-chroot ${MNTDIR} /usr/local/bin/post-base.sh

echo '===> Installing poweroff.timer'
/usr/bin/install -Dm644 /root/poweroff.timer "${MNTDIR}/etc/systemd/system/poweroff.timer"

echo '===> Preparing to reboot'
/usr/bin/umount -R ${MNTDIR}
/usr/bin/systemctl reboot

exit 0
