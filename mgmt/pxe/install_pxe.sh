#!/bin/bash

# set the environment variable to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# get the location of this script
script_dir=$(dirname $(readlink -f $0))

packages=(
		isc-dhcp-server  # dhcp server
		tftpd-hpa  # tftp server
		nfs-kernel-server  # nfs server
		pxelinux  # bootloader for pxe bootloader chain (BIOS)
		grub-efi-amd64-signed  # bootloader for pxe bootloader chain (UEFI)
		curl  # dependency to download linux mint iso
	)

# install updates
apt update
apt upgrade -y

# install packages
# unfortunately apt starts asking what to do with pre-existing configuration files
# use yes to choose the default option
yes "" | apt install -y ${packages[@]}

# configure dhcp server
# get network interface name
interface=$(ip -br l | awk '$1 !~ "lo|vir|wl" { print $1}')  # copied from the internet
# specify Ethernet interface for DHCP server
# The file /etc/default/isc-dhcp-server contains a line INTERFACESv4=""
# where the name of the Ethernet interface should be specified.
# There might be a potential comment in front of the line that needs to be removed.
sed -i "s/^\s*#\?\s*INTERFACESv4=\"\"/INTERFACESv4=\"$interface\"/" /etc/default/isc-dhcp-server

# backup old configuration file /etc/dhcp/dhcpd.conf
[ -f /etc/dhcp/dhcpd.conf ] && mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
# new configuration file
cp ${script_dir}/dhcpd.conf /etc/dhcp/dhcpd.conf

# Create directory for the pxe files
# delete existing directory
[ -d /srv/pxe ] && rm -r /srv/pxe
mkdir -p /srv/pxe
chown -R tftp:tftp /srv/pxe
chmod -R 755 /srv/pxe

# configure tftp server to serve pxe directory
[ -f /etc/default/tftpd-hpa ] && mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa.old
cp ${script_dir}/tftpd.conf /etc/default/tftpd-hpa

# copy pxelinux.0 to tftp directory
# since not all files need to be copied there is a limited selection
syslinux_files=(
	/usr/lib/PXELINUX/pxelinux.0
	/usr/lib/syslinux/modules/bios/ldlinux.c32
	)
cp ${syslinux_files[@]} /srv/pxe/

# use grub-tools to make a grub net-boot directory
grub-mknetdir --net-directory /srv/pxe/
#
# copy grub.cfg to the net-boot directory
cp ${script_dir}/grub.cfg /srv/pxe/boot/grub/grub.cfg
# NOTE:
# The line above copies a specific 'grub.cfg' file, which initiates the Linux installation process.
# This setup was specifically designed for Geekom A8 PCs.
# If a different preseed file is required for other devices, the kernel boot parameters can be modified
# to direct to an alternative preseed file within 'grub.cfg'.
#
# Grub identifies the configuration file by initially searching for one based on the MAC address of
# the network interface card. If no specific MAC-based file is found, it gradually falls back to a
# default configuration file.
# Example: If the test PC has the MAC address '01:38:f7:cd:ca:0d:f8' to which the IP-Address 192.168.0.91 is assigned (in hexadecimal: C0A8025B), Grub will search for the files
# in the following order:
# - /boot/grub/grub.cfg-01-38-f7-cd-ca-0d-f8
# - /boot/grub/grub.cfg-C0A8005C
# - /boot/grub/grub.cfg-C0A8005
# - /boot/grub/grub.cfg-C0A800
# - /boot/grub/grub.cfg-C0A80
# - /boot/grub/grub.cfg-C0A8
# - /boot/grub/grub.cfg-C0A
# - /boot/grub/grub.cfg-C0
# - /boot/grub/grub.cfg-C
# - /boot/grub/grub.cfg
#
# Therefore, to accommodate other devices, 'grub.cfg' can be customized by creating files named
# according to the IP address patterns (which are statically assigned via the mac address), as shown above.
# For instance, the current configuration file could be renamed (e.g., 'grub.cfg-C0A8') to match
# specific criteria, although this approach is untested yet and just a proposal
#
# Consideration for future development:
# Ideally, the preseed file path could be dynamically defined by the mac address, and stored as a variable within grub
# Afterwards grub sources a default configuration file to boot the system.
# Further adjustments may be needed as the system requirements evolve.


# create directory for linux mint files and copy the content of the iso into this directory
mkdir -p /srv/pxe/linuxmint
# use another script to download the current linux mint iso
iso=$(${script_dir}/mint_dl.sh)
# check if the script returned an error
if [ $? -ne 0 ]; then
	echo "Error: Downloading iso file failed!"
	exit 1
fi
# no error: Continue
# mount the iso file and copy the content to the pxe directory
mkdir -p /mnt/mintiso  # TODO: change to temp-dir
mount -o loop $iso /mnt/mintiso
cp -r /mnt/mintiso/* /srv/pxe/linuxmint
umount /mnt/mintiso
rm $iso

# copy preseed file to iso
cp ${script_dir}/preseed.cfg /srv/pxe/linuxmint/preseed.cfg
# copy post-install script to the same location
cp ${script_dir}/post_install.sh /srv/pxe/linuxmint/post_install.sh

# configure boot parameters for pxe
mkdir -p /srv/pxe/pxelinux.cfg
cp ${script_dir}/pxelinux.conf /srv/pxe/pxelinux.cfg/default

# configure nfs server
# backup old configuration file /etc/exports
[ -f /etc/exports ] && mv /etc/exports /etc/exports.old
# new content for configuration file
cp ${script_dir}/exports.conf /etc/exports
# update the exports
exportfs -a

# restart all services to apply the changes
systemctl restart isc-dhcp-server tftpd-hpa nfs-kernel-server
