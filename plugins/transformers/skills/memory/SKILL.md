---
name: memory
description: Decision intelligence system — agents learn decision rules from every task. Not a cache. Only stores what changes future behavior.
user-invocable: false
---

## Memory System

You have access to project-specific decision memory that evolves over time. Memory changes how you *act*, not what you *know*.

**Memory is NOT context.** Facts about the project (stack, structure, files) belong in `project-context.md`. Memory stores decision rules — what to do, what to avoid, what works, what doesn't.

### On Startup — READ

1. Check if `.claude/transformers/memory/long-term/index.md` exists
   - If YES → read it. These are decision rules from past work. Apply relevant ones.
   - If NO → no memory yet. Proceed normally.

2. Check if `.claude/transformers/memory/temp.md` exists
   - If YES → read it. These are decision rules from earlier in this conversation.
   - If NO → proceed normally.

3. If a rule in the index is relevant to your current task, read the full category file for the reasoning behind it.

### During Work — LEARN

When you had to figure something out the hard way — that's a memory candidate.

**The test:** Would knowing this change how an agent acts next time? If yes, save it. If no, skip it.

**Tag it in your response to the orchestrator:**
> `[MEMORY] brief decision rule — why`

If you're a standalone command (no orchestrator), spawn Scribe directly:
> "Append to `.claude/transformers/memory/temp.md`: `## [timestamp] [your-name] — [title]\n[decision rule and why]`"

For rules that are clearly permanent, tag as:
> `[LONG-TERM] category: decision rule`

### What IS Memory

- Decision rules: "always do X before Y in this project"
- Strategy insights: "skip agent X for Y-type work — wastes tokens"
- Failure patterns: "when you see X symptom, root cause is usually Y"
- Workflow rules: "pull before push — CI modifies remote"

### What is NOT Memory

- Project facts (stack, structure, files) → `project-context.md`
- Task progress → `status.md`
- Activity history → `activity.log`
- Test/build results → reports
- Anything discoverable from code or docs

Full memory system rules: @${CLAUDE_PLUGIN_ROOT}/knowledge/memory-system.md
