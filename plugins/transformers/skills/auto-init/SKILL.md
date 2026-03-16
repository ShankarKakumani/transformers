---
name: auto-init
description: Auto-checks project context, logs activity, and cleans up old data. Loaded by Optimus and Megatron on every command.
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

**After completing any command**, log what was done:

1. **Append** a one-line entry to `.claude/transformers/activity.log`:
   ```
   [YYYY-MM-DD HH:MM] [command] [brief description] [files touched count]
   ```
   Example:
   ```
   2026-03-16 14:30 feature Built dark mode toggle — 4 files changed
   2026-03-16 15:45 debug Fixed null error in login flow — root cause: missing null check in auth_bloc.dart
   2026-03-16 16:00 test Megatron tested auth module — 2 issues found (1 HIGH, 1 LOW)
   ```

2. **Create** `.claude/transformers/` directory and `activity.log` if they don't exist.

3. **Cleanup** — if the log has entries older than 7 days, remove them. Keep only the last 7 days.

## Directory Structure

Ensure this structure exists (create as needed):
```
.claude/transformers/
├── project-context.md    ← from /transformers:init
├── activity.log          ← append after every command
└── reports/              ← from /transformers:report
    └── 2026-03-16.md
```
