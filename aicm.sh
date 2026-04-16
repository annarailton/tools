#!/usr/bin/env zsh

# This is a tiny script that suggests a git commit message using Codex.
tmp=$(mktemp)
git diff --cached | codex exec -m gpt-5.4-mini -o "$tmp" "propose a conventional commit message for these changes, one line preferred but not obligatory. output only the message, nothing else." >/dev/null 2>/dev/null
msg=$(<"$tmp")
rm "$tmp"

if [[ -z "$msg" ]]; then
  print "No commit message was generated."
  exit 1
fi

print
print -- "$msg"
print

read -q "confirm?Commit with this message? [y/N] "
print

if [[ "$confirm" == [Yy] ]]; then
  git commit -m "$msg"
fi
