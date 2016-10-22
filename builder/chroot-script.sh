#!/bin/bash
set -ex

# configure and enable resolved
ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
DEST=$(readlink -m /etc/resolv.conf)
mkdir -p "$(dirname "$DEST")"
echo "nameserver 8.8.8.8" > "${DEST}"
systemctl enable systemd-resolved

cat >> /etc/pacman.conf <<- EOF
[bsn]
Server = http://packages.bluesense.co
EOF

pacman -Sy --noconfirm --needed puppet openssh sudo bsn-base
ssh-keygen -A
systemctl enable bsn-firstboot

# add user and add him to the group that is the same as his username
useradd --create-home --user-group "$USERNAME"
if [ -n "$PASSWORD" ]; then
  echo "$USERNAME:$PASSWORD" | /usr/sbin/chpasswd
fi

mkdir /home/$USERNAME/.ssh
echo "$SSH_KEY" > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME

echo "$USERNAME ALL=NOPASSWD: ALL" > "/etc/sudoers.d/user-$USERNAME"
chmod 0440 "/etc/sudoers.d/user-$USERNAME"

# remove archlinux default user
userdel -r alarm

# append build metadata for debugging
echo "BUILD_NUMBER=$BUILD_NUMBER" > /etc/bsn-release

mkdir -p /etc/puppetlabs/facter/facts.d
cat > /etc/puppetlabs/facter/facts.d/bsn.yaml <<- EOF
---
project: ${PROJECT}
build_number: ${BUILD_NUMBER}
EOF

echo $DEFAULT_HOSTNAME > /etc/hostname
sed -i "/^\[Hostname\]$/,/^\[/ s/^prefix = .*/prefix = ${HOSTNAME_PREFIX}/" /etc/bsn/bsn.ini
