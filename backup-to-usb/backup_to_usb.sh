#!/bin/bash
#
# Use rsync to copy files from $HOME to a user selected media (e.g. USB flash)

# TODO: Log/email errors? It is likely the user won't report them.

#source=$HOME/Documents
source=$HOME/
destination='/Backups/'

#rsync_zenity_awk='/usr/local/bin/backup_to_usb_rsync.awk'
rsync_zenity_awk='backup_to_usb_rsync.awk'
#rsync_filter='.rsync-backup-filter'
rsync_filter='.rsync-usbflash-filter'

#######################################
# Output error message to stderr
#######################################
err() {
	echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}


# Request device mount-point from user
until [[ 1 -eq 0 ]]; do
	mount=$( \
		sed -n 's/^[^ ]\+[[:space:]]\(\/media\/[^/ ]\+\)[[:space:]].*$/\1/p' /proc/mounts \
		| sed 's/\\040/ /' \
		| zenity --list --column "Available devices" \
			--title "Choose sync device" \
			--text "Select the device to synchronise to:" \
	)
	# If the user pressed Cancel, we exit the script
	if [[ $? -ne 0 ]]; then
		err "Operation canceled by user"
		exit 1
	fi
	# If $mount contains a string, we can exit the loop
	if [[ -n "${mount}" ]]; then
		break
	fi
done


# Check destination path is a valid dir
path=${mount}${destination}
if [[ ! -d "$path" ]]; then
	err "Backup path not a directory [${path}]"
	zenity --error \
		--title "Error: No backup directory" \
		--text "Backup path not a directory:\n${path}"
	exit 1
fi



# The rsync/zenity progress code was borrowed from this site:
# https://davidverhasselt.com/zenity-rsync-and-awk/

# Use rsync to copy files from source to destination; log and report any errors
errmsg=$(( \
	rsync -av --progress --delete --filter='dir-merge ${rsync_filter}' "$source" "$path" \
	| awk -f ${rsync_zenity_awk} \
	| zenity --progress --title "Backing up to ${mount}" \
		--text="Please wait..." --percentage=0 --auto-kill \
	) 2>&1)

if [[ -n "$errmsg" ]]; then
	err "Errors occured during rsync:\n${errmsg}"
	zenity --error \
		--title "Error: rsync problem" \
		--text "Errors occured during rsync:\n\n${errmsg}"
	exit 1
fi

