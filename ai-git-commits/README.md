# AI Git Commits

`ai-git-commits.sh` suggests a conventional commit message from your staged diff

There is then the option to commit directly, edit it or just ditch the whole thing. 

## Dependencies

This script expects [`llm`](https://github.com/simonw/llm) to be installed and available on your `PATH`.

Install it with:

```bash
brew install llm
```

You will also need to add an OpenAI API key with 

```bash
llm keys set openai
```

## Usage

Add this function to `~/.zshrc`:

```zsh
acm() {
  $${REPO_PATH}/tools/ai-git-commits/ai-git-commits.sh "$@"
}
```

Reload your shell:

```bash
source ~/.zshrc
```

Then you can run (with staged changes!)

```bash
acm
acm -h
acm --high
```

## Modes

| Mode | Model | Diff |
| --- | --- | --- |
| default | `gpt-5.4-mini` | `git diff --cached --unified=0` |
| `--high` or `-h` | `gpt-5.4` | `git diff --cached` |
