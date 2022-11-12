#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

FORCE="${FORCE:=n}"
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
			if [[ "${f,,}" =~ .*"sync".* && "$FORCE" != "y" ]]; then
				echo "skipping directory \"$f\" because it contains \"sync\" in its path, rerun with FORCE=y to override." >&2
				continue
			fi
			list_removed "$f"/* &
		fi
	done

	wait
}

list_removed $@

