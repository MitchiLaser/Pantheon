#!/bin/bash

packages=(
	# packages to build glass dependencies
	# maybe important when installing it on a non-ix86 architecture
	unzip
	libtool
	autoconf
	automake
	make
	# package to run glass, not a dependency
	nodejs
)

# install nodejs and nodesource
# I don't know if i can install nodesource via the package manager or if i manually have to update the following link:
curl -sL https://deb.nodesource.com/setup_23.x | bash -
apt install -y ${packages[@]}

# store cwd to return to it later
current_dir=$(pwd)

# install glass
[ -d /opt/glass-isc-dhcp ] && rm -rf /opt/glass-isc-dhcp
git clone https://github.com/Akkadius/glass-isc-dhcp.git /opt/glass-isc-dhcp
cd /opt/glass-isc-dhcp
mkdir logs
chmod u+x ./bin/ -R
chmod u+x *.sh

npm install
npm install forever -g

# return to previous working directory
cd ${current_dir}

# specify admin username and password
sed -i "s/\"admin_user\": .*,/\"admin_user\": \"root\",/" /opt/glass-isc-dhcp/config/glass_config.json
# read password from secret file, only first line, remote newline and in the end shell-escape the string
password=$(cat ./../../secrets/password.txt | head -n 1 | tr -d '\n' | sed -e 's/[&/]/\\&/g')
sed -i "s/\"admin_password\": .*,/\"admin_password\": \"${password}\",/" /opt/glass-isc-dhcp/config/glass_config.json

# the glasses server is not started. Instead, a systemd service unit should be created
[ -f /etc/systemd/system/glass.service ] && rm /etc/systemd/system/glass.service
cat << EOF > /etc/systemd/system/glass.service
[Unit]
Description=Glass ISC DHCP Server
After=network.target

[Service]
WorkingDirectory=/opt/glass-isc-dhcp
ExecStart=node ./bin/www
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable glass
systemctl start glass

# extend apparmor configuration for isc dhcp server to access
# files created by glass during runtime
if ! grep -q '# glass' /etc/apparmor.d/usr.sbin.dhcpd; then
	# add glass rectory to apparmor profile as readable
	sed -i '/^}/i\
  # glass gui\n  /opt/glass-isc-dhcp/* r,' /etc/apparmor.d/usr.sbin.dhcpd

	# restart apparmor
	systemctl restart apparmor
fi
