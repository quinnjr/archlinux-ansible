#!/usr/bin/env bash
set -eu

echo '===> Installing Virtualbox'
/usr/bin/pacman -S --noconfirm linux-headers virtualbox-guest-utils virtualbox-guest-modules-arch nfs-utils

echo '===> Enabling virtualbox services'
/usr/bin/systemctl enable vboxservice.service
/usr/bin/systemctl enable rpcbind.service

echo '===> Adding vagrant user to vboxsf group'
/usr/bin/gpasswd -a vagrant vboxsf

exit 0
