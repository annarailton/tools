#!/bin/bash
set -euo pipefail
snapshot_scripts="$(cd -- "$(dirname -- "$0")" && pwd)"
snapshot_build="$snapshot_scripts/.build"
snapshot_binary="$snapshot_build/snapshot"
if [[ ! -x "$snapshot_binary" || "$snapshot_scripts/capture.swift" -nt "$snapshot_binary" || "$snapshot_scripts/Info.plist" -nt "$snapshot_binary" ]]; then
    printf 'Snapshot helper is missing or outdated. Run bash %s/install.sh from Terminal.\n' "$snapshot_scripts" >&2
    exit 1
fi
exec "$snapshot_binary" "$@"
