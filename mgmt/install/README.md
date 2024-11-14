# Installation Process

This is a documentation of the installation process of the Debian Linux distribution for the mgmt server.

1. Download the latest Debian ISO from the official website: [https://www.debian.org/](https://www.debian.org/)
2. Insert the USB Stick into the PC and check which device-descriptor it is assigned to. Then execute the following commands **as root** here /dev/sdX is the device-descriptor of the USB stick:
```bash
# create a new partition table and a new fat32 partition 
parted --script /dev/sdX mklabel msdos
parted --script /dev/sdX mkpart primary fat32 0% 100%
mkfs.vfat /dev/sdX1

# mount the empty USB stick partition
mkdir -p /mnt/usb
mount /dev/sdX1 /mnt/usb

# mount the ISO file as a loop device
mkdir -p /mnt/cdrom
mount -o loop debian-xx-amd64-netinst.iso /mnt/cdrom  # use the correct path to the ISO file
sudo rsync -av /mnt/cdrom/ /mnt/usb/
sudo umount /mnt/cdrom
sudo rmdir /mnt/cdrom
````
3. Copy the `preseed.cfg` file and the `post_install.sh` from this directory to the root of the USB stick (`/mnt/usb/`)
4. Add the kernel parameters to start the automatic installation process by editing the `boot/grub/grub.cfg` file on the USB stick. Go go the section for the `menuentry 'Graphical install'` and append the following lines to the `linux` parameter: `DEBCONF_DEBUG=5 auto=true priority=critical preseed/file=/cdrom/preseed.cfg`
5. unmount the usb thumb drive (remove temporary directory) and start installation process. Choose the Graphical installer in the GRUB menu. This is going to automatically install the Debian OS on the server with a predefined user that can be accessed over ssh with a private key provided in this repository.

After the installation process is finished, the server can be accessed with the secret ssh key: `ssh -o "IdentitiesOnly=yes" -i path_to_repo/secrets/id_ed25519 root@192.168.0.10`. There is no DHCP server running on the mgmt machine, therefore the SSH client needs a static ip address for the first connection. The Addresses .2 to .9 are available for this purpose.

After the installation process is finished, the scripts to setup the services (pxeboot including DHCP, Ansible, ...) can be copied to the server via scp and executed.


## MISC

### Specify the password in the preseed file

You need the `mkpasswd` utility from the `whois` package to generate the password hash. You can install it with the following command: `printf "r00tpassw0rd" | mkpasswd -s -m md5`.

There is a directory to test the preseeded installation in a virtual machine. This directory contains some scripts and a manual on how to use it. Furthermore here are a couple of notes on this:

### How to write a preseed file?

The honest answer is: It's painful to debug and you never wanna do this from scratch. There are available resources for this you can take a look at:
- [Something I found online](https://r-pufky.github.io/docs/docs/operating-systems/ubuntu/preseed/create-preseed-file.html)
- [Debian preseed example file](https://www.debian.org/releases/stable/example-preseed.txt)
