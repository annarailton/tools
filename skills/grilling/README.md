# Grilling skill

Adapted from [Matt Pocock's grilling skill](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) for the Codex VS Code extension. It asks one decision at a time through Codex's structured input UI when available, with a chat fallback for clients or modes that do not expose that tool.

## Setup

From the tools repository root:

```sh
bash skills/grilling/install.sh
```

This installs the adapted `grilling` and fetches the original `grill-with-docs` and `domain-modeling` from [Matt Pocock's skills repository](https://github.com/mattpocock/skills). It uses Codex's built-in GitHub skill installer. Existing dependency installs are reused; the script will not overwrite a different copy of `grilling`.

In a new Codex VS Code chat, use `$grilling` for a normal interview or `$grilling with docs: <your plan>` to run the upstream docs workflow with the same interactive questions.
