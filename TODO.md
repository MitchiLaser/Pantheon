# To-Do List

- [ ] Replace shell script for pxe boot server installation with ansible role
- [ ] During the installation process the post-install script should take the network configuration and make it static. This makes the network resistant in case the DHCP server stops working.
- [ ] Add the python "simplemonitor" package to the whole system. The mgmt machine collects the monitoring status from all remote devices and simultaneously checks its own services and notifies the admin via email if something is wrong. This is an easy approach to monitor the whole network and embed remote wakeup calls for the devices in case they cannot be reached. There are ansible roles required to set up the monitoring system because it should be running in different modes on either the mgmt machine or all remote devices.
