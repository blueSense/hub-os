#!/bin/bash
set -ex

# this script should be run only inside of a Docker container
if [ ! -f /.dockerinit ]; then
  echo "ERROR: script works only in a Docker container!"
  exit 1
fi

### setting up some important variables to control the build process
IMAGE_PATH="/image/rpi-raw.img"
SD_CARD_SIZE=1500
BOOT_PARTITION_SIZE=64

# create empty BOOT/ROOTFS image file
# - SD_CARD_SIZE in MByte
# - DD uses 256 Bytes
# - sector block size is 512Bytes
# - MBR size is 512 Bytes, so we start at sector 2048 (1MByte reserved space)
BOOTFS_START=2048
BOOTFS_SIZE=$((BOOT_PARTITION_SIZE * 2048))
ROOTFS_START=$((BOOTFS_SIZE + BOOTFS_START))
SD_MINUS_DD=$((SD_CARD_SIZE * 1024 * 1024 - 256))
ROOTFS_SIZE=$((SD_MINUS_DD / 512 - ROOTFS_START))

dd if=/dev/zero of=${IMAGE_PATH} bs=1MiB count=${SD_CARD_SIZE}

DEVICE=$(losetup -f --show ${IMAGE_PATH})

echo "Image ${IMAGE_PATH} created and mounted as ${DEVICE}."

# create partions
sfdisk --force "${DEVICE}" <<PARTITION
unit: sectors
/dev/loop0p1 : start= ${BOOTFS_START}, size= ${BOOTFS_SIZE}, Id= c
/dev/loop0p2 : start= ${ROOTFS_START}, size= ${ROOTFS_SIZE}, Id=83
/dev/loop0p3 : start= 0, size= 0, Id= 0
/dev/loop0p4 : start= 0, size= 0, Id= 0
PARTITION

losetup -d "${DEVICE}"
DEVICE=$(kpartx -va ${IMAGE_PATH} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1)
dmsetup --noudevsync mknodes
BOOTP="/dev/mapper/${DEVICE}p1"
ROOTP="/dev/mapper/${DEVICE}p2"
DEVICE="/dev/${DEVICE}"

# give some time to system to refresh
sleep 3

# create file systems
mkfs.vfat "${BOOTP}"
mkfs.ext4 "${ROOTP}" -L root -i 4096 # create 1 inode per 4kByte block (maximum ratio is 1 per 1kByte)

mkdir /build
mount "${ROOTP}" /build

mkdir /build/boot
mount "${BOOTP}" /build/boot

fdisk -l "${IMAGE_PATH}"
