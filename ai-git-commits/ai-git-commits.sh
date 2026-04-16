#!/usr/bin/env zsh
# This is a tiny script that suggests a git commit message using an LLM based on the staged changes.

MODEL="gpt-5.4-mini"
DIFF_ARGS=(--cached --unified=0)
PROMPT="Propose a conventional commit message for these changes, one line preferred but not obligatory. Output only the message, nothing else"


# Guard against empty staged changes
if git diff --cached --quiet; then
	print "No staged changes."
	exit 0
fi

# Deal with any options
# By default we use a smaller model & a more restricted diff to save time & tokens
# If user picks `--high` we use the full diff and more powerful model.
for arg in "$@"; do
	case "$arg" in
	-h | --high)
		MODEL="gpt-5.4"
		DIFF_ARGS=(--cached) # Use the full diff for the high quality model
		;;
	--help)
		print "Usage: aicm.sh [-h|--high]"
		print
		print "  -h, --high   Use gpt-5.4 and the full staged diff"
		exit 0
		;;
	*)
		print "Unknown option: $arg" >&2
		print "Usage: aicm.sh [-h|--high]" >&2
		exit 1
		;;
	esac
done

# Generate the commit message using the specified model and diff
msg=$(git diff "${DIFF_ARGS[@]}" | llm -m "$MODEL" -s "$PROMPT" 2>/dev/null)

# Guard against empty message (likely to be an error in the model)
if [[ -z "$msg" ]]; then
	print "No commit message was generated."
	exit 1
fi

# Print commit message and ask user what they want to do with it
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
