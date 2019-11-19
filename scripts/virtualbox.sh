#!/bin/bash -e

sudo pacman -S --noconfirm virtualbox-guest-utils-nox virtualbox-guest-modules-arch
sudo systemctl enable vboxservice
sudo systemctl start vboxservice
sudo pacman -Scc --quiet --noconfirm &>/dev/null
rm -rf /ect/machine-id