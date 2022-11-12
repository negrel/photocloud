#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

: ${EXIF_FIX="disabled"}
: ${CLEAN_REMOVED="disabled"}
: ${PHOTOSORT_OUTDIR=""}
: ${TZ=""}

# Set timezone
if [ -n "TZ" ]; then
	ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
	echo "$TZ" > /etc/timezone
fi

# Check PHOTOSORT_OUTDIR paramter
if [ -z "$PHOTOSORT_OUTDIR" ]; then
	echo "ERROR - photosort out directory is not specified"
	exit 1
fi
if [ ! -d "$PHOTOSORT_OUTDIR" ]; then
	echo "ERROR - \"$PHOTOSORT_OUTDIR\" is either not a directory or don't exist"
	exit 1
fi

case "$EXIF_FIX" in
	""|"disabled")
		echo "INFO - exif fix disabled"
		;;

	"monthly"|"weekly"|"daily"|"hourly")
		cron_dir="/etc/periodic/$EXIF_FIX"
		cron_script="$cron_dir/exif_fix"
		cat <<EOF > "$cron_script"
#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

exec exif_fix.sh $PHOTOSORT_OUTDIR
EOF
		chmod +x "$cron_script"
		echo "INFO - exif fix will be executed $EXIF_FIX"
		;;

	*)
		echo "ERROR - \"$EXIF_FIX\" is an invalid value for \$EXIF_FIX: must be one of \"disabled\", \"monthly\", \"weekly\", \"daily\", \"hourly\""
		exit 1
		;;
esac


case "$CLEAN_REMOVED" in
	""|"disabled")
		echo "INFO - cleaning of removed files disabled"
		;;

	"monthly"|"weekly"|"daily"|"hourly")
		cron_dir="/etc/periodic/$CLEAN_REMOVED"
		cron_script="$cron_dir/clean_removed"
		cat <<EOF >> "$cron_script"
#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

exec list_removed.sh $PHOTOSORT_OUTDIR | xargs -I{} /bin/sh -c 'echo "Removing {}..."; rm -f "{}"'
EOF
		chmod +x "$cron_script"
		echo "INFO - cleaning of removed files will be executed $CLEAN_REMOVED"
		;;

	*)
		echo "ERROR - \"$CLEAN_REMOVED\" is an invalid value for \$CLEAN_REMOVED: must be one of \"disabled\", \"monthly\", \"weekly\", \"daily\", \"hourly\""
		exit 1
		;;
esac

exec crond -f -L /dev/stdout

