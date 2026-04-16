#!/usr/bin/env zsh
# This is a tiny script that suggests a git commit message using an LLM based on the staged changes.

model="gpt-5.4-mini"
diff_args=(--cached --unified=0)

for arg in "$@"; do
  case "$arg" in
    -h|--high)
      model="gpt-5.4"
      diff_args=(--cached)  # Use the full diff for the high quality model
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

# Guard against empty staged changes
if git diff --cached --quiet; then
	print "No staged changes."
	exit 0
fi

msg=$(git diff "${diff_args[@]}" | llm -m "$model" -s "Propose a conventional commit message for these changes, one line preferred but not obligatory. Output only the message, nothing else." 2>/dev/null)

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
