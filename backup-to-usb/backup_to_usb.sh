#!/bin/bash

# Might be worth emailing any errors... as the user likely won't report them... and/or use logger?

#source=$HOME/Documents
source=$HOME/
destination='/Backups/'


# Infinite loop
until [ 1 -eq 0  ]; do
	mount=$( \
		sed -n 's/^[^ ]\+[[:space:]]\(\/media\/[^/ ]\+\)[[:space:]].*$/\1/p' /proc/mounts | \
		sed 's/\\040/ /' | \
		zenity --list --column "Available devices" \
			--title "Choose sync device" \
			--text "Select the device to synchronise to:" \
	)
	# If the user pressed Cancel, we exit the script
	if [ $? -ne 0 ]; then
		printf "Operation canceled by user\n" >&2
		exit 1
	fi
	# If $mount contains a string, we can exit the loop
	test "$mount" && break
done


path=$mount$destination


if [ ! -d "$path" ]; then
	printf "Backup path not a directory [%s]\n" "$path" >&2
	zenity --error \
		--title "Error: No backup directory" \
		--text "Backup path not a directory:\n$path"
	exit 2
fi



# The rsync/zenity progress stuff was borrowed from this site:
# http://blog.crowdway.com/2008/12/24/zenity-rsync-and-awk/

errmsg=$(( \
	rsync -av --progress --delete --filter='dir-merge .rsync-backup-filter' "$source" "$path" | \
	awk -f /usr/local/bin/backup_to_usb_rsync.awk | \
	zenity --progress --title "Backing up to $mount" \
		--text="Please wait..." --percentage=0 --auto-kill \
	) 2>&1)

if [ -n "$errmsg" ]; then
	printf "Errors occured during rsync:\n%s\n" "$errmsg" >&2
	zenity --error \
		--title "Error: rsync problem" \
		--text "Errors occured during rsync:\n\n$errmsg"
	exit 3
fi

