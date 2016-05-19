#!/bin/bash
set -ex

# configure and enable resolved
ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
DEST=$(readlink -m /etc/resolv.conf)
mkdir -p "$(dirname "$DEST")"
echo "nameserver 8.8.8.8" > "${DEST}"
systemctl enable systemd-resolved

pacman -Sy --noconfirm --needed openssh sudo bsn-autoupdate

bsn-autoupdate --onetime --no-start

ssh-keygen -A

# add user and add him to the group that is the same as his username
useradd --create-home --user-group "$USERNAME"
if [ -n "$PASSWORD" ]; then
  echo "$USERNAME:$PASSWORD" | /usr/sbin/chpasswd
fi

mkdir /home/$USERNAME/.ssh
echo "$SSH_KEY" > /home/$USERNAME/.ssh/authorized_keys

echo "$USERNAME ALL=NOPASSWD: ALL" > "/etc/sudoers.d/user-$USERNAME"
chmod 0440 "/etc/sudoers.d/user-$USERNAME"

# remove archlinux default user
userdel -r alarm

# append build metadata for debugging
echo "BUILD_NUMBER=$BUILD_NUMBER" > /etc/bsn-release
