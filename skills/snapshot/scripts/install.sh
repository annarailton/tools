#!/bin/bash
set -euo pipefail

snapshot_source="$(cd -- "$(dirname -- "$0")/.." && pwd)"
snapshot_destination="${1:-${CODEX_HOME:-$HOME/.codex}/skills/snapshot}"
mkdir -p "$snapshot_destination"
rsync -a --exclude='.build/' "$snapshot_source/" "$snapshot_destination/"

snapshot_scripts="$(cd -- "$snapshot_destination/scripts" && pwd)"
snapshot_build="$snapshot_scripts/.build"
mkdir -p "$snapshot_build"
xcrun swiftc "$snapshot_scripts/capture.swift" -o "$snapshot_build/snapshot" \
    -module-cache-path "$snapshot_build/module-cache" \
    -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker "$snapshot_scripts/Info.plist"
codesign --force --sign - --identifier dev.railton.snapshot "$snapshot_build/snapshot"
printf 'Installed snapshot skill at %s\n' "$snapshot_destination"
