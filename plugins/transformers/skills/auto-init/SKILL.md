---
name: auto-init
description: Auto-checks project context, logs activity via scribe, and manages the activity log and artifact directories. Loaded by Optimus and Megatron on every command.
user-invocable: false
---

## Project Context Check

Before starting any work:

1. **Does `.claude/transformers/context/project.md` exist?**
   - If NO → tell the user: "This project hasn't been initialized for Transformers yet. Run `/transformers:init` first for best results, or I can proceed without project context."
   - If YES → load it silently and proceed.

2. **Is it stale?** Check the "Generated on" date in the file.
   - If older than 24 hours → mention once: "Project context is from [date]. Run `/transformers:init --update` to refresh, or I'll work with what we have."
   - Don't block — just mention it.

## Memory Check

Before starting work, load project memory:

1. **Long-term memory index** — read `.claude/transformers/memory/long-term/index.md` if it exists
   - Silently absorb relevant learnings. Don't announce them unless directly relevant to the current task.
   - If a learning is relevant, read the full category file for details.

2. **User patterns** — always read `.claude/transformers/memory/long-term/user-patterns.md` in full if it exists
   - These are behavioral preferences learned from past corrections and redirects. Apply them immediately.
   - Don't announce them — just use them.

3. **Temp memory** — read `.claude/transformers/memory/temp.md` if it exists
   - These are learnings from earlier in this conversation. Apply them.

3. If neither exists → no memory yet. Proceed normally. Memory will grow as agents work.

## Artifact Directory Check

For lifecycle commands (`feature`, `bugfix`, `research`):

1. **Prune stale `.temp/` entries** — spawn Scribe to delete any subdirectory under `.claude/transformers/.temp/` whose `status.md` has a timestamp older than 2 days. If no `status.md` exists in a folder, delete it too.

2. **Check for in-progress work** in `.claude/transformers/.temp/`
   - If a matching artifact directory exists with `status.md` showing incomplete work → "Found in-progress work for [name]. Want to resume or start fresh?"
   - If starting fresh with a name collision → append a number (`features/search-2`)

2. **Ensure directory structure exists**:
```
.claude/transformers/
├── context/
│   ├── project.md        ← from /transformers:init
│   └── pr-preferences.md ← from /transformers:pr-generator
├── memory/
│   ├── temp.md           ← per-conversation learnings
│   └── long-term/        ← cross-conversation learnings
│       ├── index.md      ← one-line summaries (loaded on every command)
│       └── [category].md ← detailed learnings by topic
├── reports/              ← from /transformers:report
│   └── activity.log      ← scribe appends after every command
└── .temp/                ← in-progress and completed feature/bugfix artifacts
    ├── features/
    └── bugfix/
```

## Activity Logging

**After completing any command**, spawn `scribe` to log what was done.

Tell scribe exactly what to write — one line in this format:
```
YYYY-MM-DD HH:MM [command] [brief description] [files touched count]
```

Example instructions to scribe:
- "Append to `.claude/transformers/reports/activity.log`: `2026-03-16 14:30 feature Built dark mode toggle — 4 files changed`"
- "Append to `.claude/transformers/reports/activity.log`: `2026-03-16 16:00 bugfix Fixed null pointer in auth flow — 2 files changed`"

Scribe handles directory creation, appending, and pruning entries older than 7 days.
