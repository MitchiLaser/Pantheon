# To-Do List

- [ ] Replace shell script for pxe boot server installation with ansible role
- [ ] Make mDNS work: The DHCP-Server provides hostnames for the statically configured clients. Currently mDNS is working but it uses the default "unassigned" hostname from the preseed file. This has to be replaced with the hostname from the dhcp server to make mDNS work propperly. Afterwards the ansible inventory can be rewritten to use the hostnames instead of the IP addresses.
- [ ] During the installation process the post-install script should take the network configuration and make it static. This makes the network resistant in case the DHCP server stops working.
