#!/bin/bash

# This is a script which uses QEMU to start a VM or set up the VM with a pre-defined installer
# when the virtual hard-drive cannot be found. It was made to quickly recreate a new VM in case
# the old one was deleted (maybe because someone messed arround with it)
# All the arguments QEMU needs to start the VM with the right parameters
# are also stored in this script and can be modified.
# The default OS installer is currently a Link to the OpenSUSE net installer


###################
## Configuration ##
###################

# Specify SSH, SPICE and Telnet interface
TELNET_PORT=5925
SSH_PORT=5926

# Specify parameters of the virtual hard drive
DRIVE_SIZE=30G	# default: 30GB
DRIVE_NAME="drive.qcow2"

# parameters for the running vm
NUM_CPU_CORES=2	# number of cpu cores
RAM=4G	# memory size

####################
## QEMU Arguments ##
####################

arguments=(	# the command line arguments for the QEMU instance

	-nodefaults	# remove default configuration, p.ex. a floppy-interface

	-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time	# the host is running on the same cpu-model as the guest. Default-CPU would be "QQemu virtual CPU"
	-enable-kvm 	# enables virtualisation through KVM (kernel virtualised machine) if this module is available, root-privileges currently needed and therfore disabled

	-smp $NUM_CPU_CORES	# the amount of CPU-Cores
	-m $RAM	# The amoung of Memory. "M" and "G" can be used as units for Megabytes ans Gigabytes

	-drive format=qcow2,file=$(dirname "$0")/drive.qcow2
	# include a file or device in the VM which is presented as a physical drive to the guest.
	#-cdrom ./debian-preseeded.iso	# Installer image
	#-boot d
	-boot c

	-k de		# Keyboard-Layout
	-name "Preseed"

	# specify network-interface-controller. There are many options. I tried this one and it works
	-net user,hostfwd=tcp::${SSH_PORT}-:22 # SSH Access to the VM
	-net nic

	-object secret,id=secvnc0,data=$SPICE_PASSWORD,format=base64	# spice password has to be passed as a QEMU secret
	-vga qxl	# specify a graphics-card. "qxl" is recommended for usage with SPICE

	-monitor telnet:127.0.0.1:${TELNET_PORT},server,nowait
	# provide a QEMU-Terminal to communicate with the hyper visor.
	# "telnet" provides a serial terminal via Telnet.
	# Listening on 127.0.0.1 means that only the host can connect to the Telnet terminal

	-daemonize	# start VM as a daemon in the background

	# configure the mouse as a touchscreen / tablet and not as a classic mouse. This improves the interface for the spice client.
	-device nec-usb-xhci,id=xhci
	-device usb-tablet,bus=xhci.0

	-object rng-random,filename=/dev/urandom,id=rng0	# emulate a hardware random number generator. Use as virtio devie with:
	-device virtio-rng-pci,rng=rng0			# host frontend for the random number generator

	)

# Create virtual hard drive when missing
if [ ! -f $(dirname "$0")/drive.qcow2 ];
then
	echo "Creating virtual hdd 'drive.qcow2'"
	qemu-img create -f qcow2 $DRIVE_NAME $DRIVE_SIZE
fi

# execute QEMU vm
qemu-system-x86_64 "${arguments[@]}" \
	"$@"	# add all parameters given to this bash-script as a string to this command
