# Ansible directory

This directory contains the files for ansible to operate on all the PCs and all information to deploy the machines.

## Boot procedure

The mgmt hosts a PXE server. The boot menu can be entered by smashing the F7 key. From there on, Linux mint should radically install itself onto the machines without asking for permission.

## Linting

All the files in this directory should be checked by `ansible-lint` which can be installed via pip.
There is also a `.ansible-lint-ignore` file for this purpose in this directory.

## SSH-Key Service

The public key of all the remote hosts for ansible are stored in the /root/.ssh/known_hosts file. Sometimes keys might change.
To update this file here are two examples for the host `192.168.0.91`:
```bash
# remove old key
ssh-keygen -f /root/.ssh/known_hosts -R 192.168.0.91
# add new key
ssh-keyscan 192.168.0.91 >> /root/.ssh/known_hosts 2>/dev/null
```
