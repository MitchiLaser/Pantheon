#!/bin/bash

# this script is executed after the preseeded installation process is finished
# it needs to be copied to the target system (preseed) 
# and executed there in a chroot environment as root.
#
# install openssh server
apt install -y openssh-server
# enable ssh server
systemctl enable ssh

# set up the ssh access for the 'root' user
mkdir -p /root/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGia+zBFvTsOfpXobcLxMBXzgGbEuh1UvrJdQix5i+TR mgmt-key' > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# set up the ssh access for the 'praktikum' user
mkdir -p /home/praktikum/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGia+zBFvTsOfpXobcLxMBXzgGbEuh1UvrJdQix5i+TR mgmt-key' > /home/praktikum/.ssh/authorized_keys
chown -R praktikum:praktikum /home/praktikum/.ssh
chmod 700 /home/praktikum/.ssh
chmod 600 /home/praktikum/.ssh/authorized_keys

# disable password authentication for ssh
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# get the hostname provided by the dhcp server and inject it into the /etc/hosts file
# Make a test request with dhcpcd and get the output
DHCP_HOSTNAME=$(dhcpcd -T 2>/dev/null | grep "new_host_name=" | sed -n "s/.*='\([^']*\)'.*/\1/p")
#DHCP_DOMAIN=$(dhcpcd -T | grep "new_domain_name=" | sed -n"s/.*='\([^']*\)'.*/\1/p")  # not used

# check if there is a hostname provided by the dhcp server
# if not, exit the script and print an error message
if [[ -z "$DHCP_HOSTNAME" ]]; then
    echo "No DHCP-assigned hostname found."
    exit 1
fi

# for debugging purposes this information might be useful some time
#echo "DHCP-assigned hostname: $DHCP_HOSTNAME"

# Update /etc/hostname
[ -f /etc/hostname ] && rm /etc/hostname
echo "$DHCP_HOSTNAME" > /etc/hostname
echo "Updated /etc/hostname with DHCP-assigned hostname: $DHCP_HOSTNAME"

# Update the current hostname without reboot
# this is not done but it might be useful to keep it
#hostnamectl set-hostname "$DHCP_HOSTNAME"

