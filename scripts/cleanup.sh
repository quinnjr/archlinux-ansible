#!/usr/bin/env bash

set -eu

# Clean up the pacman cache
echo '===> Cleaning up the pacman cache'
/usr/bin/pacman -Scc --noconfirm
/usr/bin/pacman-optimize

/usr/bin/sync
