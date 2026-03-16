---
name: auto-init
description: Auto-checks project context, logs activity via scribe, and manages the activity log and artifact directories. Loaded by Optimus and Megatron on every command.
user-invocable: false
---

## Project Context Check

Before starting any work:

1. **Does `.claude/transformers/project-context.md` exist?**
   - If NO → tell the user: "This project hasn't been initialized for Transformers yet. Run `/transformers:init` first for best results, or I can proceed without project context."
   - If YES → load it silently and proceed.

2. **Is it stale?** Check the "Generated on" date in the file.
   - If older than 24 hours → mention once: "Project context is from [date]. Run `/transformers:init --update` to refresh, or I'll work with what we have."
   - Don't block — just mention it.

## Artifact Directory Check

For lifecycle commands (`feature`, `bugfix`):

1. **Check for in-progress work** in `.claude/transformers/active/`
   - If a matching artifact directory exists with `status.md` showing incomplete work → "Found in-progress work for [name]. Want to resume or start fresh?"
   - If starting fresh with a name collision → append a number (`feature-search-2`)

2. **Ensure directory structure exists**:
```
.claude/transformers/
├── project-context.md    ← from /transformers:init
├── activity.log          ← scribe appends after every command
├── active/               ← in-progress feature/bugfix artifacts
├── completed/            ← finished feature/bugfix artifacts
└── reports/              ← from /transformers:report
```

## Activity Logging

**After completing any command**, spawn `scribe` to log what was done.

Tell scribe exactly what to write — one line in this format:
```
YYYY-MM-DD HH:MM [command] [brief description] [files touched count]
```

Example instructions to scribe:
- "Append to `.claude/transformers/activity.log`: `2026-03-16 14:30 feature Built dark mode toggle — 4 files changed`"
- "Append to `.claude/transformers/activity.log`: `2026-03-16 16:00 bugfix Fixed null pointer in auth flow — 2 files changed`"

Scribe handles directory creation, appending, and pruning entries older than 7 days.
