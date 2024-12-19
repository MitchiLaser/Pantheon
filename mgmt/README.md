# MGMT

This directory contains some scripts that are used to set up the mgmt server.

## Install

Here are the files to perform a presseded installation of the Debian operating system. The README file explains how to create a custom iso with the preseed file.
There is also a subdirectory to test the preseed file in a virtual machine, although this might not work because the virtual machine might have a different virtual hard drive than the physical server (there is a difference between dsa and nvme0n1 for example).)

# Ansible

The shell script to copy the ansible configuration file and the ansible directory to the proper location on the mgmt server and to install ansible system wide.

# PXE

The shell script to copy the pxe configuration file and the pxe directory to the proper location on the mgmt server and to install the necessary packages.

# Glass

Glass is a web gui for the isc dhcp server. This script installs the necessary packages, clones the glass repository into the installation directory and sets up the system configuration including an AppArmor profile.
