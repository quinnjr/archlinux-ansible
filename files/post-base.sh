#!/usr/bin/env bash

set -eu

FQDN='vagrant'
KEYMAP='us'
LANG='en_us.UTF-8'
PASSWD=$(/usr/bin/openssl passwd -crypt 'vagrant')
TIMEZONE='UTC'
DISK='/dev/sda'

echo '===> Setting up the system'
/usr/bin/grub-install ${DISK}
/usr/bin/grub-mkconfig -o /boot/grub/grub.cfg

echo ${FQDN} > /etc/hostname
/usr/bin/ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo KEYMAP=${KEYMAP} > /etc/vconsole.conf
/usr/bin/sed -i "s/#${LANG}/${LANG}/" /etc/locale.gen
/usr/bin/locale-gen
/usr/bin/mkinitcpio -p linux
/usr/bin/usermod --password ${PASSWD} root

/usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

/usr/bin/systemctl enable dhcpcd@eth0.service
/usr/bin/systemctl start dhcpcd@eth0.service
/usr/bin/systemctl enable sshd
/usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

/usr/bin/useradd --password ${PASSWD} --comment 'Vagrant User' --create-home --user-group vagrant
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10-vagrant
/usr/bin/install -d --owner=vagrant --group=vagrant -m 0700 /home/vagrant/.ssh
/usr/bin/curl -o /home/vagrant/.ssh/authorized_keys -O https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
/usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys

exit 0
