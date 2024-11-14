#!/bin/bash

# this script is executed after the preseeded installation process is finished
# it needs to be copied to the target system (preseed) 
# and executed there in a chroot environment as root.

# set up the ssh access
mkdir -p /root/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGia+zBFvTsOfpXobcLxMBXzgGbEuh1UvrJdQix5i+TR mgmt-key' > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# disable password authentication for ssh
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# disable root login for ssh
#sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
