#!/usr/bin/env zsh
# This is a tiny script that suggests a git commit message using Codex
# Suggests a commit based on staged changes only

# Guard against empty staged changes
if git diff --cached --quiet; then
	print "No staged changes."
	exit 0
fi

msg=$(git diff --cached | llm -m gpt-5.4-mini -s "Propose a conventional commit message for these changes, one line preferred but not obligatory. Output only the message, nothing else." 2>/dev/null)

if [[ -z "$msg" ]]; then
	print "No commit message was generated."
	exit 1
fi

print
print -- "$msg"
print

read "choice?Commit with this message? [y]es / [e]dit / [N]o: "

if [[ "$choice" == [Yy] ]]; then
	print
	git commit -m "$msg"
elif [[ "$choice" == [Ee] ]]; then
	print
	git commit --edit -m "$msg"
fi
