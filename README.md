# Pantheon

In ancient times, a pantheon was a sanctuary dedicated to all the gods. Nowadays this is a setup to provide a uniform way to manage a large herd of computers in a university network.
**Wait, What?**
The Physics faculty at KIT introduced a large number of computers in their lab course, thus replacing the old windows machines with a new setup. With this step a paradigm shift is introduced: Linux is the new standard operating system and a centralised management system is needed to keep the machines up to date and to provide a uniform environment for the students. With the intention to reduce the maintenance workload and to provide a more stable environment, the Pantheon project was born.

## What is it for?

Currently the network is in a state of transition. The old windows machines are being replaced by new Linux machines step by step. All new Linux machines are going to be managed the following way:

- Install Linux Mint from a PXE server using a preseed file and a minimum set of custom scripts, providing the most basic setup for the next step
- Provide a centralised deployment using Ansible to install all necessary software and to configure the machines. This includes the setup for the lab experiments, the user accounts and the network configuration
- To reduce the necessity of USB thumb drives, all data acquired during the lab experiments is stored on a central server and can be accessed from home after the lab course.

The Pantheon aims to provide these features in the simplest but simultaneously most robust way possible as the people responsible for the lab course are not IT professionals. The setup should be easy to maintain and to extend, if possible it should be self-explanatory. Less means more: The less components there are the less can go wrong (hopefully).

## How does it work?

Haha, you thought I documented it? Well, I didn't because I don't get paid enough for this project. But I can give you a rough overview:

- The heart of the project is a machine dedicated for the control of the whole network, formerly called "management" (mgmt). This machine provides all the necessary services the network is relying on.
- The PXE server is a simple setup using isc-dhcp-server and tftp-hpa. The preseed file is provided by the nfs server running on the same machine. The preseed file is a minimal setup to install Linux Mint completely without user interaction. After the installation process is finished, the machine runs a custom script to enable SSH access from a pre-defined key public key and performs a basic network configuration. Both are needed for Ansible.
- The Ansible setup is a bit more complex. The machines are grouped by their role (e.g. lab machine, server, etc.) and the setup is split into multiple playbooks. There should be playbooks and roles for every task that needs to be done. The playbooks are run by the management machine and the configuration is stored in a git repository. The git repository is cloned to the management machine and the playbooks are run from there. It is important to keep this repository up to date to ensure that the machines can be updated and configured properly.
- The central server is a simple setup using NFS. The server provides a shared folder for the lab experiments and a shared folder for the user data with the later one being accessible from home via a HTTP(s) connection. The server only operates within the university network and is not accessible from the outside but a VPN connection is possible.

## What can I find in the directories of this repository?

- `mgmt`: Within this directory the setup and configuration process of the management server (`mgmt`) is automated. It contains a collection of shell scripts to set up the management server from scratch and also a preseed configuration file to install the operating system. All the necessary documentation for this should be available in this directory.
- `ansible`: This directory contains the Ansible playbooks and roles to configure the machines in the network. Most of the maintenance work should be done within this directory to keep the environments up to date.
- `sh-scripts`: before the transition to ansible some of the old shell scripts are kept there as a reference for documentation purposes. They are not used anymore and should be removed in the future.
- `Roadmap`: A presentation - not useful anymore
- `secrets`: This directory is a submodule and it should never be pushed to this repository. It contains the private ssh key and a password file to access the machines in the network.
