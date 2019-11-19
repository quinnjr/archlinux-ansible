#!/bin/bash -e

sudo pacman -S --noconfirm linux-headers qemu-guest-agent &>/dev/null
sudo pacman -Scc --quiet --noconfirm &>/dev/null
rm -rf /ect/machine-id