# To-Do List

The entries in this list are sorted by priority with the highest priority at the top.

- [ ] During the installation process the post-install script should take the network configuration and make it static. This makes the network resistant in case the DHCP server stops working.
- [ ] Add a backup solution for the mgmt machine. The SCC provides storage for this. The Backup should cover all the files in /srv and the Git repository for the management process. This backup should also be monitored (simplemonitor).
- [ ] Configure sshd to listen on a second port. In production the mgmt machine should be accessible from the outside only for the ports 80 and 443 (HTTP / HTTPs) and the second ssh port which is not the default port 22. This is a security measure to prevent brute force attacks on the ssh port while still being able to access the machine from the outside. Furthermore we have to configure fail2ban to be active on the exposed ssh port.

## Low Priority

- [ ] Better indexing page for apache2, see https://perishablepress.com/better-default-directory-views-with-htaccess/ and https://wrcraig.com/ApacheDirectoryDescriptions/ and https://httpd.apache.org/docs/2.0/mod/mod_autoindex.html
    - alternatively: Create an own php script that indexes the files and directories in a more user-friendly way. This should also give the possibility to download files and directories as a zip archive.
- [ ] Replace shell script for pxe boot server installation with ansible role. This also applies to the glass_install script. The ansible role should also update the git repo / linux mint iso and the pxe boot configuration files (preseed, bootloader-configuration).
- [ ] Add the python "simplemonitor" package to the whole system. The mgmt machine collects the monitoring status from all remote devices and simultaneously checks its own services and notifies the admin via email if something is wrong. This is an easy approach to monitor the whole network and embed remote wakeup calls for the devices in case they cannot be reached. There are ansible roles required to set up the monitoring system because it should be running in different modes on either the mgmt machine or all remote devices.
- [ ] Switch from isc-dhcp-server to kea dhcp server and replace glass with stork (from isc). Since 2022 isc dhcp server is no longer maintained and the kea dhcp server is the successor. The stork project is a web interface for the kea dhcp server provided by isc.
