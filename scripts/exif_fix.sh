#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

command -v exiftool &> /dev/null || (echo "exiftool is not installed"; exit 1)

MAX_JOB="${MAX_JOB:=256}"
ulimit -u "$MAX_JOB"

exif_date() {
	exiftool -AllDates "$1" 2> /dev/null | head -n 1 | cut -d ':' -f 2- | xargs
}

exif_fix() {
	for f in "$@"; do
		if [ -f "$f" ]; then
			exif_fix_file "$f" &
		elif [ -d "$f" ]; then
			exif_fix_directory "$f" &
		else
			echo "skipping \"$f\", not a file nor a directory" >&2
		fi
	done

	wait
}

exif_fix_directory() {
	local dir="$1"

	echo "fixing directory \"$dir\"..."
	for f in "$dir"/*; do
		exif_fix "$f" &
	done

	wait
	echo "directory \"$dir\" fixed."
}

exif_fix_file() {
	local file="$1"
	local exif_date="$(exif_date "$file")"

	if [ "$exif_date" = "" ]; then
		echo "fixing file \"$file\"..."

		local month="$(basename $(dirname "$file"))"
		local year="$(basename $(dirname $(dirname "$file")))"

		exiftool -AllDates="$year:$month:01 00:00:00" "$file" 2> /dev/null
	else
		echo "skipping \"$file\" file, exif date already defined ($exif_date)" >&2
	fi
}

exif_fix $@
wait
echo "exif fix done"

