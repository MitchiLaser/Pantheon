#!/bin/bash

# this script installs the Quartus Prime Lite software

source ./config.sh

# please update the quartus download source to the newest version
q_installer_source="https://downloads.intel.com/akdlm/software/acdsinst/23.1std.1/993/qinst/qinst-lite-linux-23.1std.1-993.run"

# create temporary file for the quartus installer
qinst_tempfile=$(mktemp -p /tmp -t XXXXXX.qinstall.run)
wget -o /dev/null -O ${qinst_tempfile} ${q_installer_source}
chmod +x ${qinst_tempfile}

# another temporary directory for the extracted installer
qinst_extr=$(mktemp -d -p /tmp -t XXXXXX.qinstall)

# now extract the quartus installer to make use of it
${qinst_tempfile} --quiet --accept --nox11 --chown --noexec --noexec-cleanup --keep --target ${qinst_extr}
rm ${qinst_tempfile}

# change permission so that the installer can be run by another user than root!
# For reasons I don't wanna explain in detail here, I don't want the installer to be run by root
# Also, I don't trust this installer at all. Screw this shit and never give it root permissions!
chown -R ${adm_user}:${adm_user} ${qinst_extr}

# prepare installation directory
if [[ -d ${quartus_install_dir} ]]
then
  rm -rf ${quartus_install_dir}
fi
mkdir -p ${quartus_install_dir}
chown -R ${adm_user}:${adm_user} ${quartus_install_dir}
chmod -R 775 ${quartus_install_dir}

installer=${qinst_extr}/qinst.sh
# run the installer as the regular user, not root!
download_temp_dir=$(mktemp -d -p /tmp -t XXXXXX.qinstall_temp)  # download installer files for temporary use
chown -R ${adm_user}:${adm_user} ${download_temp_dir}  # again: installer is not root!
sudo -u ${adm_user} ${installer} --cli --accept-eula --download-dir ${download_temp_dir} --install-dir ${quartus_install_dir} --auto-install --parallel-downloads 4 --components quartus,max

# cleanup after installation
rm -rf ${qinst_extr}
rm -rf ${download_temp_dir}
rm -rf /tmp/installbuilder_installer.log  # dunno where this file came from but it can be removed
rm -f /tmp/.quartus.*

# Now the configuration of the environment needs to be performed
# first, install the quartus.desktop file in the right location to make Quartus visible in the application menu
cat << EOF > /usr/share/applications/quartus.desktop
[Desktop Entry]
Version=1.0
Name=Quartus Prime Lite
Comment=Quartus Prime Lite design software for Intel FPGAs
Exec=/opt/intelFPGA/quartus/bin/quartus --64bit
Icon=/opt/intelFPGA/quartus/adm/quartusii.png
Terminal=false
Type=Application
Categories=Development
EOF

# now install the udev rules for the USB Blaster
cat << EOF > /etc/udev/rules.d/51-usbblaster.rules
# USB-Blaster
ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="660", TAG+="uaccess"
ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="660", TAG+="uaccess"
ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="660", TAG+="uaccess"

# USB-Blaster II
ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="660", TAG+="uaccess"
ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="660", TAG+="uaccess"
EOF

# TODO: install the EU-Symbol patch in the MAXwel Git Repository
