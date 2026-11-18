#!/usr/bin/env bash
# Install this repo's VS Code adaptation of grilling alongside Matt Pocock's
# original grill-with-docs and domain-modeling skills

set -euo pipefail

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codex_dir="${CODEX_HOME:-$HOME/.codex}"
dest="${1:-$codex_dir/skills}"
installer="$codex_dir/skills/.system/skill-installer/scripts/install-skill-from-github.py"

paths=()
for skill in grill-with-docs domain-modeling; do
  if [[ -f "$dest/$skill/SKILL.md" ]]; then
    printf 'Using existing %s at %s\n' "$skill" "$dest/$skill"
  elif [[ -e "$dest/$skill" || -L "$dest/$skill" ]]; then
    printf 'Cannot install into existing path: %s\n' "$dest/$skill" >&2
    exit 1
  else
    paths+=("skills/engineering/$skill")
  fi
done

if [[ -e "$dest/grilling" || -L "$dest/grilling" ]]; then
  if ! cmp -s "$source_dir/SKILL.md" "$dest/grilling/SKILL.md"; then
    printf 'Cannot replace existing grilling at %s\n' "$dest/grilling" >&2
    exit 1
  fi
fi

if (( ${#paths[@]} )); then
  python3 "$installer" --method git --repo mattpocock/skills --dest "$dest" --path "${paths[@]}"
fi

if [[ ! -f "$dest/grilling/SKILL.md" ]]; then
  mkdir -p "$dest/grilling"
  cp "$source_dir/SKILL.md" "$source_dir/LICENSE" "$dest/grilling/"
fi
