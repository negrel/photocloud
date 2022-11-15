#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

: ${EXIF_FIX="disabled"}
: ${TRASH_REMOVED="disabled"}
: ${EMPTY_TRASH="disabled"}
: ${PHOTOSORT_OUTDIR=""}
: ${TZ=""}

# Set timezone
if [ -n "TZ" ]; then
	ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
	echo "$TZ" > /etc/timezone
fi

# Check PHOTOSORT_OUTDIR parameter
if [ -z "$PHOTOSORT_OUTDIR" ]; then
	echo "ERROR - photosort out directory is not specified"
	exit 1
fi
if [ ! -d "$PHOTOSORT_OUTDIR" ]; then
	echo "ERROR - \"$PHOTOSORT_OUTDIR\" is either not a directory or don't exist"
	exit 1
fi

cron_job() {
	local name="$1"
	local desc="$2"
	local recurr="$3"
	local bin="$4"

	case "$recurr" in
		""|"disabled")
			echo "INFO - $desc disabled"
			;;

		"monthly"|"weekly"|"daily"|"hourly")
			cron_dir="/etc/periodic/$recurr"
			chmod +x "$bin"
			mv "$bin" "$cron_dir"
			echo "INFO - $desc will be executed $recurr"
			;;

		*)
			echo "ERROR - \"$recurr\" is an invalid value for \"$name\" cron job: must be one of \"disabled\", \"monthly\", \"weekly\", \"daily\", \"hourly\""
			exit 1
			;;
	esac
}

cron_job "EXIF_FIX" "exif fix" "$EXIF_FIX" "/jobs/exif_fix"
cron_job "TRASH_REMOVED" "trash of removed files" "$TRASH_REMOVED" "/jobs/trash_removed"
cron_job "EMPTY_TRASH" "empty of trash directory" "$EMPTY_TRASH" "/jobs/empty_trash"

exec crond -f -L /dev/stdout

