#!/bin/bash

xorriso -as mkisofs -o ./debian-preseeded.iso -isohybrid-mbr cdrom/isolinux/isolinux.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -J -r -V "Custom Debian" ./cdrom/
