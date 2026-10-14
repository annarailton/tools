---
name: snapshot
description: Immediately take a camera snapshot and load it into Codex context when invoked.
---

# Snapshot

Invocation authorizes one photo. Say "Taking a snapshot now", then immediately run:

```sh
bash <absolute-skill-directory>/scripts/capture.sh --output <unique-absolute-path.jpg>
```

Run the shell tool with `sandbox_permissions: "require_escalated"` on the first call, a PTY, and short yield. Camera discovery inside the sandbox can return no devices even when cameras are connected; do not treat that as proof no camera exists. Never bypass rejected approval.

Honor a named camera with `--camera "<name or ID>"`. If automatic selection fails, use `--list` with the same camera access and retry once with the sole external webcam; ask if selection is ambiguous.

Save under the workspace's `work/camera-snapshots/` with a timestamp plus UUID. Cancel with Ctrl-C if requested. Allow macOS permission prompts; report failures.

After `status: saved` and successful exit, load the returned image into Codex context with `view_image` and display it inline using `![Snapshot](<absolute-path>)`. Describe or analyze it only if the user's accompanying request calls for that. Preserve the photo; never overwrite or silently retake it.
