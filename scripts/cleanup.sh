#!/usr/bin/env bash

set -eu

# Clean up the pacman cache
/usr/bin/pacman -Scc --noconfirm
/usr/bin/pacman-optimize

/usr/bin/sync

exit 0
