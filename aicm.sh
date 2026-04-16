# This is a tiny script that suggests a git commit message using Codex
msg=$(git diff --cached | codex exec -m gpt-5.4-mini "propose a conventional commit message for these changes, one line preferred but not obligatory. output only the message, nothing else.")
echo "\n$msg\n"
read "confirm?Commit with this message? [y/N] "
if [[ "$confirm" == "y" ]]; then
    git add -A && git commit -m "$msg"
fi
