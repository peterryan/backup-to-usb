#!/bin/bash
#
# Use rsync to copy files from $HOME to a user selected media (e.g. USB flash)

# TODO: Log/email errors? It is likely the user won't report them.

source_path="${HOME}/"
target_location='Backups/'			# This relative path is appended to the media device path.

rsync_filter='.rsync-usbflash-filter'
rsync_zenity_awk='backup_to_usb_rsync.awk'
zenity_icon='/usr/local/share/icons/backup_to_usb.svg'
dryrun=''
mount_point=''
target_path=''
script_dir="$(dirname "$(realpath "$0")")"
rsync_awk_path="${script_dir}/${rsync_zenity_awk}"


#######################################
# Output usage info.
# Globals:
#   $0
#   $rsync_filter
# Arguments:
#   None
# Returns:
#   None
#######################################
usage() {
cat << EOF
Usage: ${0##*/} [f filename] [-n] [-h]

    -f    set rsync per-dir filter filename (default ${rsync_filter})
    -n    dry-run
    -h    display this help text and exit
EOF
}


#######################################
# Output error message to stderr.
# Globals:
#   None
# Arguments:
#	$*=Error message
# Returns:
#   None
#######################################
err() {
	echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}


#######################################
# Request media mount-point from user (via zenity dialogues).
# Globals:
#   $mount_point
# Arguments:
#   None
# Returns:
#   None
#######################################
get_mount_point() {
	until [[ 1 -eq 0 ]]; do
		mount_point=$( \
			awk '{ print $2 }' /proc/mounts \
			| grep '^/media' \
			| zenity --list --column "Available devices" \
				--title "Choose sync device" \
				--text "Select the device to synchronise to:" \
				--window-icon "${zenity_icon}" \
		)
		# If the user pressed Cancel, we exit the script
		if [[ $? -ne 0 ]]; then
			err "Operation canceled by user"
			exit 1
		fi
		# If $mount_point contains a string, we can exit the loop
		if [[ -n "${mount_point}" ]]; then
			break
		fi
	done
}


#######################################
# Check target_path is a valid directory.
# Globals:
#	$target_location
#   $mount_point
#	$target_path
# Arguments:
#   None
# Returns:
#   None
#######################################
validate_target_path() {
	target_path="${mount_point}/${target_location}"
	if [[ ! -d "$target_path" ]]; then
		err "Backup path not a directory [${target_path}]"
		zenity --error \
			--title "Error: No backup directory" \
			--text "Backup path not a directory:\n${target_path}"
		exit 1
	fi
}


#######################################
# Execute rsync to sync files with target_path
# Globals:
#   $source_path
#	$target_path
#	$dryrun
#	$rsync_filter
#	$rsync_zenity_awk
#	$mount_point
# Arguments:
#   None
# Returns:
#   None
#######################################
sync_files() {
	# The rsync/zenity progress code was borrowed from this site:
	# https://davidverhasselt.com/zenity-rsync-and-awk/

	# NOTE: Using "-rltDvz" instead of "-a" to prevent sync of perms/uid/guid
	#       And --modify-window=1 is to aid sync with FAT partiions
	errmsg=$(( \
		rsync -rltDvz ${dryrun} --progress --delete --modify-window=1 \
			--filter="dir-merge /${rsync_filter}" "$source_path" "$target_path" \
		| awk -f "${rsync_awk_path}" \
		| zenity --progress --title "Backing up to ${mount_point}" \
			--text="Please wait..." --percentage=0 --no-cancel --auto-close \
			--width=600 --window-icon "${zenity_icon}" \
	) 2>&1)

	if [[ -n "$errmsg" ]]; then
		err "Errors occured during rsync:\n${errmsg}"
		zenity --error \
			--title "Error: rsync problem" \
			--text "Errors occured during rsync:\n\n${errmsg}"
		exit 1
	fi

	zenity --info --text="Backup complete" --width=250 --window-icon "${zenity_icon}"
}


#######################################
# Process command line arguments and start rsync process.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
main() {
	# Process command line options
	while getopts "f:nh" opt; do
		case "$opt" in
			f)
				rsync_filter="$OPTARG"
				;;
			n)
				dryrun='-n'
				;;
			h)
				usage
				exit 0
				;;
			\?)
				usage
				exit 1
				;;
		esac
	done
	shift $(($OPTIND - 1))

	get_mount_point
	validate_target_path
	sync_files
}


main "$@"

