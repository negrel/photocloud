#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

exec list_removed.sh "$PHOTOSORT_OUTDIR" | xargs -I{} /bin/sh -c 'echo "Removing {}..."; rm -f "{}"'
