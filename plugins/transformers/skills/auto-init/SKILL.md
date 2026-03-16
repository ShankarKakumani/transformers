---
name: auto-init
description: Auto-checks project context, logs activity via scribe, and manages the activity log. Loaded by Optimus and Megatron on every command.
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

## Activity Logging

**After completing any command**, spawn `scribe` to log what was done.

Tell scribe exactly what to write — one line in this format:
```
YYYY-MM-DD HH:MM [command] [brief description] [files touched count]
```

Example instructions to scribe:
- "Append to `.claude/transformers/activity.log`: `2026-03-16 14:30 feature Built dark mode toggle — 4 files changed`"
- "Append to `.claude/transformers/activity.log`: `2026-03-16 16:00 test Megatron tested auth module — 2 issues found (1 HIGH, 1 LOW)`"

Scribe handles directory creation, appending, and pruning entries older than 7 days.

## Directory Structure

Scribe ensures this structure exists:
```
.claude/transformers/
├── project-context.md    ← from /transformers:init
├── activity.log          ← scribe appends after every command
└── reports/              ← from /transformers:report
    └── 2026-03-16.md
```
