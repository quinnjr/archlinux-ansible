#!/bin/bash
set -e
set -x

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo -e 'vagrant\nvagrant' | passwd
useradd -m -U vagrant
echo -e 'vagrant\nvagrant' | passwd vagrant

cat <<EOF > /etc/polkit-1/rules.d/50-nopasswd-vagrant.rules
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("vagrant")) {
        return polkit.Result.YES;
    }
});
EOF

cat <<EOF > /etc/sudoers.d/vagrant
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/vagrant

install -dm0700 -o vagrant -g vagrant /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys && chmod 0600 /home/vagrant/.ssh/authorized_keys

ln -s /dev/null /etc/systemd/network/99-default.link

cat <<EOF > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
EOF

echo 'archlinux' > /etc/hostname

localectl set-keymap "us"
timedatectl set-ntp true

systemctl enable sshd
systemctl enable systemd-networkd
systemctl enable systemd-resolved

grub-install "${vhd}"
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
