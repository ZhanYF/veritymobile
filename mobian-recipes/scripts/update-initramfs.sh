#/bin/sh

set -e

# We must mount a devtmpfs to find which device support the LUKS
# rootfs
trap 'umount /dev' EXIT
mount -t devtmpfs none /dev

update-initramfs -u
