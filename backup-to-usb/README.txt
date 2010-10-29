Install the following files to /usr/local/bin/
	backup_to_usb.sh
	backup_to_usb_icon.svg
	backup_to_usb_rsync.awk

**Need information on permissions! Obv. script needs to be executable.


Then copy the rsync filter file to home directory:
	$ cp -p EXAMPLE.rsync-backup-filter ~/.rsync-backup-filter

Create a new Gnome panel launcher with the following settings:
	Name: Backup to USB
	Command: /usr/local/bin/backup_to_usb.sh
	Comment: Backup Documents to USB memory

and set the icon to the SVG icon file.

