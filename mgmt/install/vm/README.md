# Installation test

This directory contains a script to start a virtual machine to test the installation process.
This is rueful when you have issues with preseed and want to debug your script.
To use it you have to do the following steps:
1. Create two directories: `iso` and `cdrom`.
2. Download the current Debian iso and put it in this directory. Mount it as a loop device: `sudo mount -o loop debian.iso iso`.
3. Copy all files from the mounted iso to the `cdrom` directory: `rsync -av iso/ cdrom/`. Afterwards you can send the original iso file with the loop-mount to hell!
4. Change the kernel boot parameters as needed in the following file: `isolinux/gtk.cfg`. Changes in the `grub.cfg` do not work because QEMU boots into öegacy mode (no UEFI).
5. Copy the `preseed.cfg` and the `post_install.sh` to the `cdrom` directory.

From here on you change the content of the `preseed.cfg` and the `post_install.sh` to your needs and use the script to generate a custom iso. Then you can start the virtual machine with the `vm.sh` script.

You should have an SSH access to the VM on localhost:5926 and you can access the QEMU monitor via `telnet localhost 5925` (no password). There you can use the command `sendkey ctrl-alt-f2` to switch to the second console and debug the installation process. The 4th console is the installation log. When the installation is finished you can comment the `-cdrom` option in the `vm.sh` script and start the VM again to test the installed system. In case you messed up: just delete the virtual hard drive and start over.




## MISC - Only read when you have nothing better to do!

Here are some notes to things I encountered while I tried to get the installation process working.

### Grub Kernel Parameters now available after boot

Possibly the system is not booting in UEFI mode (where it uses grub) but in legacy mode instead. Therefore the changes to the kernel parameter need to be done in the following file: `isolinux/gtk.cfg` which is responsible for the graphical installer. There are many config files for different boot options, the root file is `isolinux/isolinux.cfg` which then imports all the other files recursively.

