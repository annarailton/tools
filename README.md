# tools

Home of small tools to make my life better

| Tool | Description |
| - | - | 
| [`ai-git-commits`](ai-git-commits) | LLM suggests a git commit from your diff |
| [`snapshot`](skills/snapshot) | Codex skill for immediate camera snapshots, for when you need Codex to interact in meat-space |
| [`grilling`](skills/grilling) | Codex skill for interviewing one decision at a time with interactive questions when available |

## Skills

### Snapshot (Mac only)

Install this skill before using it so its Swift camera helper is compiled and signed ahead of time, avoiding compliation delays.

To install or update the snapshot skill from this repository:

```sh
bash skills/snapshot/scripts/install.sh
```

### Grilling

Use this skill when you want Codex to stress-test a plan or decision. It asks one question at a time using Codex's structured question UI when available, and falls back to a plain chat question in clients or modes without it. See [`skills/grilling/README.md`](skills/grilling/README.md) for setup, including installation of Matt Pocock’s original `grill-with-docs` and `domain-modeling` skills. The adapted skill retains the upstream MIT license and attribution to Matt Pocock.
