#!/bin/bash

# get the location of this file
script_dir=$(dirname $(readlink -f $0))

# make sure python 3 and pip are available
apt install -y python3 python3-pip pipx

if [ -z "$(pipx list | grep ansible-core)" ]; then
	# install ansible with argcomplete
	pipx install ansible-core
	pipx inject --include-apps ansible-core argcomplete
	pipx inject --include-apps ansible-core ansible-lint
else
	# upgrade installation
	pipx upgrade --include-injected ansible-core
fi

# make applications installed by pipx available in the shell
pipx ensurepath
# enable pipx shell completion
[ -z "$(cat ~/.bashrc | grep 'register-python-argcomplete pipx')" ] && echo 'eval "$(register-python-argcomplete pipx)"' >> ~/.bashrc

# now apply the changes in the configuration files to the shell
source ~/.bashrc

# install configuration file
[ -f /etc/ansible/ansible.cfg ] && mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.old
mkdir -p /etc/ansible
cp ${script_dir}/../../ansible/ansible.cfg /etc/ansible/ansible.cfg  # shitty location!

# create link for ansible directory from the git repository to root home directory
# so that it matches the path in the configuration file
[ -d /root/ansible ] && rm -f /root/ansible
ln -s ${script_dir}/../../ansible /root/ansible

# install the mgmt ssh key
[ -f /root/.ssh/id_ed25519 ] && mv /root/.ssh/id_ed25519 /root/.ssh/id_ed25519.old
[ -f /root/.ssh/id_ed25519.pub ] && mv /root/.ssh/id_ed25519.pub /root/.ssh/id_ed25519.pub.old
cp ${script_dir}/../../secrets/id_ed25519* /root/.ssh/

