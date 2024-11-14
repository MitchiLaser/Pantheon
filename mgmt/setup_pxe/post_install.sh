#!/bin/bash

# this script is executed after the preseeded installation process is finished
# it needs to be copied to the target system (preseed) 
# and executed there in a chroot environment as root.
#
# install openssh server
apt install -y openssh-server
# enable ssh server
systemctl enable ssh

# set up the ssh access
mkdir -p /home/praktikum/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGia+zBFvTsOfpXobcLxMBXzgGbEuh1UvrJdQix5i+TR mgmt-key' > /home/praktikum/.ssh/authorized_keys
chown -R praktikum:praktikum /home/praktikum/.ssh
chmod 700 /home/praktikum/.ssh
chmod 600 /home/praktikum/.ssh/authorized_keys

# disable password authentication for ssh
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
