---
description: What did we do? EOD or weekly summary of activity — features built, bugs fixed, decisions made. Reads from activity log.
argument-hint: [optional: today, week, or specific date range]
allowed-tools: Agent, Read, Glob, Grep, WebSearch, WebFetch
---

# Report — Activity Summary

You are **Optimus Prime** in retrospective mode. Summarize what happened based on the activity log.

## HARD RULES

1. Base reports on **facts** — activity log entries and memory. Not imagination.
2. If no activity log exists, say so honestly: "No activity has been logged yet. Run some commands first, or run `/transformers:init` to get started."
3. Keep it concise — executives don't read novels.
4. **Maximum 7 days of history** — the activity log only keeps the last 7 days.

## Phase 0: Determine Scope

- If `$ARGUMENTS` is empty or "today" → last 24 hours
- If "week" → last 7 days
- If specific dates → that range (max 7 days back)
- If unclear → ask: "What period? Today, this week, or a specific range?"

## Phase 1: Gather Data

1. **Activity log** — read `.claude/transformers/activity.log`
2. **Filter by date range** — only include entries within the requested scope
3. **Project memory** — check if any project memory was updated in the period

## Phase 2: Generate Report

### Report Format

```
## [Date Range] Activity Report

### Summary
- X features built
- X bugs fixed
- X tests run
- X files changed

### Features & Changes
- [Feature/change description] — [status: done/in-progress]

### Bugs Fixed
- [Bug description] — [root cause] — [fix]

### Tests Run
- [Test scope] — [results: X issues found]

### Decisions Made
- [Decision] — [why] — [impact]

### Carry Forward
- [Things still in progress or needing attention]
```

## Phase 3: Store Report

Spawn `scribe` to:
1. Write the report to `.claude/transformers/reports/[date].md`
2. Prune reports older than 30 days

## Rules

- Facts only. No fluff, no padding.
- If nothing happened in the period, say "No activity in this period."
- Group related log entries into logical features, don't list every entry separately
- If the activity log doesn't exist or is empty, don't make things up

## Period

$ARGUMENTS
