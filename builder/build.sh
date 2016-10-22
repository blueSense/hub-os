#!/bin/bash

ROOTFS_DIR="/build"

# bootstrap a minimal arch linux rootfs
tar -zxf /archlinuxlatest/ArchLinuxARM-rpi-2-latest.tar.gz -C /build

# try to emulate arm if built on a different platform
if [[ ! $(uname -m) == *"arm"* ]]; then
  cp $(which qemu-arm-static || echo ) "$ROOTFS_DIR/usr/bin"
  update-binfmts --enable qemu-arm
fi

# modify/add image files directly
cp -R /builder/files/* "$ROOTFS_DIR/"

# set up mount points for the pseudo filesystems
mkdir -p "$ROOTFS_DIR/proc" "$ROOTFS_DIR/sys" "$ROOTFS_DIR/dev/pts"

mount -o bind /dev "$ROOTFS_DIR/dev"
mount -o bind /dev/pts "$ROOTFS_DIR/dev/pts"
mount -t proc none "$ROOTFS_DIR/proc"
mount -t sysfs none "$ROOTFS_DIR/sys"

chroot "$ROOTFS_DIR" /bin/env -i \
  USERNAME="$USERNAME" \
  PASSWORD="$PASSWORD" \
  SSH_KEY="$SSH_KEY" \
  BUILD_NUMBER="$BUILD_NUMBER" \
  PROJECT="$PROJECT" \
  DEFAULT_HOSTNAME="$DEFAULT_HOSTNAME" \
  HOSTNAME_PREFIX="$HOSTNAME_PREFIX" \
  /bin/bash < /builder/chroot-script.sh

# unmount pseudo filesystems
umount -l "$ROOTFS_DIR/dev/pts"
umount -l "$ROOTFS_DIR/dev"
umount -l "$ROOTFS_DIR/proc"
umount -l "$ROOTFS_DIR/sys"

# ensure that there are no leftover artifacts in the pseudo filesystems
rm -rf "$ROOTFS_DIR/{dev,sys,proc}/*"

umount "$ROOTFS_DIR/boot"
umount "$ROOTFS_DIR"

echo "### remove dev mapper devices for image partitions"
kpartx -vds "/image/rpi-raw.img" || true

umask 0000

cd image
zip "rpi-raw.img.zip" "rpi-raw.img"
