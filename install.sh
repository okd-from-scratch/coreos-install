#!/usr/bin/env bash
# Based on https://logout.hu/bejegyzes/mr_dini/telepitsunk_fedorat_futo_rendszerre.html
set -e
if [ "$EUID" -ne 0 ]
  then echo "You have to run this script as root"
  exit
fi

modprobe xfs
modprobe btrfs
apt update
apt install -y git squashfs-tools gcc
cd /root
wget https://cdimage.debian.org/mirror/cdimage/release/current-live/amd64/iso-hybrid/debian-live-12.4.0-amd64-standard.iso -O debian.iso
mount -o ro debian.iso /mnt
mkdir -p /takeover
mount -t tmpfs tmpfs /takeover -o size=8G
cd /takeover
unsquashfs -d ./ -f /mnt/live/filesystem.squashfs
umount /mnt
rm -rf /takeover/lib/modules/*
cat /etc/resolv.conf > /takeover/etc/resolv.conf
sed -e '/trusted=yes/d' -i /takeover/etc/apt/sources.list
chroot /takeover apt update
chroot /takeover apt install openssh-server -y
mkdir /takeover/run/sshd
sed -i s"|#PermitRootLogin prohibit-password|PermitRootLogin yes|" /takeover/etc/ssh/sshd_config
wget https://www.busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-x86_64 -O /takeover/busybox
chmod +x /takeover/busybox
cd /takeover
git clone https://github.com/marcan/takeover.sh ./takeover
mv ./takeover/* ./
mv ./takeover/.* ./
rm ./takeover/ -rf
gcc fakeinit.c -o fakeinit -static
sed -i 's|^./busybox mount -t devpts devpts dev/pts|./busybox mount --bind /dev/pts dev/pts|' /takeover/takeover.sh
rm -f /takeover/etc/motd
curl -o /takeover/root/coreos-installer https://raw.githubusercontent.com/okd-from-scratch/coreos-install/main/coreos-installer
chmod +x /takeover/root/coreos-installer
curl -o /takeover/takeover.sh https://raw.githubusercontent.com/okd-from-scratch/coreos-install/main/takeover.sh
curl -o - https://raw.githubusercontent.com/okd-from-scratch/coreos-install/main/bashrc >> /takeover/root/.profile
mkdir -p /takeover/root/.ssh
chmod 0700 /takeover/root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ41/3CaLxtJsKIav76+C7C6wPS1m9VoZKLxYHJf5ZRd user1" > /takeover/root/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhLt6Wtr7l1OW0L42YzJipnaorS/umnU8LZSC+9bjsV user2" >> /takeover/root/.ssh/authorized_keys
chmod 0600 /takeover/root/.ssh/authorized_keys
chmod +x /takeover/takeover.sh
sh /takeover/takeover.sh
