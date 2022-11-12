#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

MAX_JOB="${MAX_JOB:=256}"
ulimit -u "$MAX_JOB"

list_removed() {
	for f in "$@"; do
		if [ -f "$f" ]; then
			local link_count="$(stat -c '%h' "$f")"
			test "$link_count" = "1" && echo "$f" 
		elif [ -L "$f" ]; then
			stat -L "$f" &> /dev/null && echo "$f"
		elif [ -d "$f" ]; then
			list_removed "$f"/* &
		fi
	done

	wait
}

list_removed $@

