# Memory System — Decision Intelligence

Memory is NOT a cache. It's how agents make better decisions over time.

**The distinction:**
- `project-context.md` = what the project is (facts, stack, structure, file locations)
- `Memory` = how to work smarter in it (decision rules, strategies, what to avoid, what works)

**The test:** If a memory doesn't change how an agent *acts*, it doesn't belong in memory. "This project uses React" is context. "Always run lint before commit here — pre-commit hook is broken" is a decision rule.

## Memory Types

### Temporary Memory — `.claude/transformers/memory/temp.md`

Per-conversation decision context shared across all active work.

**What goes here:**
- Failed approaches and why ("tried X, broke Y — don't repeat")
- Decision shortcuts found during this session ("need to run Z before W")
- Cross-task warnings ("Jazz found auth silently swallows errors — Ironhide, handle defensively")

**Format:**
```
## [timestamp] [agent] — [brief title]
[1-2 line decision rule — what to do or avoid, and why]
```

**Lifecycle:**
- Created at first learning in a conversation
- Any agent can read and append
- Cleared when conversation ends naturally
- Before clearing: orchestrator reviews for graduation candidates

### Long-term Memory — `.claude/transformers/memory/long-term/`

Persists across conversations. Decision rules organized by topic. This is how the plugin evolves per project.

**Categories are open-ended** — create new ones as the project needs them. Use kebab-case filenames. Examples:
- `git-workflow.md` — Decision rules for git operations
- `build-deploy.md` — What to do/avoid when building or deploying
- `testing-strategy.md` — Which test approaches work, which waste time
- `debugging-rules.md` — Decision shortcuts for common symptom patterns
- `agent-efficiency.md` — Which agents to use/skip for which work
- `project-gotchas.md` — Non-obvious behaviors that affect decisions

**Format per file:**
```
# [Category Title]

## [decision rule title]
**Learned:** [date] | **Source:** [command/agent]
**Rule:** [what to do or avoid]
**Why:** [what happened that taught us this]

---
```

## Memory Operations

### READ — Before Acting

**Auto-init loads the memory index** on every command:
1. Read `.claude/transformers/memory/long-term/index.md` (one-line decision rules)
2. Read `.claude/transformers/memory/temp.md` if it exists
3. Apply relevant rules to current decisions

**When to deep-read:** If the index mentions a relevant rule, read the full category file for the reasoning behind it.

### WRITE — After Learning

**The trigger:** An agent had to figure something out the hard way. That figuring-out IS the memory.

**Who can write:**
- **Orchestrators** (Optimus/Megatron) — decide what's worth remembering from lifecycle commands
- **Standalone commands** (debug, commit-and-push, etc.) — write directly via Scribe
- **Sub-agents** — propose via tags in their summary: `[MEMORY] always pull before push — CI auto-bumps versions`

**How to write:**
1. Agent discovers a decision rule through trial, error, or observation
2. Spawns Scribe with explicit instructions:
   - Temp: "Append to `.claude/transformers/memory/temp.md`: [entry]"
   - Long-term: "Add to `.claude/transformers/memory/long-term/[category].md`: [entry]. Update `index.md`."

### GRADUATE — Temp to Long-term

Graduation = "this session learning applies everywhere, not just today."

1. **End of lifecycle command** — Orchestrator reviews temp, promotes decision rules that are project-wide
2. **Explicit tag** — Any agent can tag `[LONG-TERM] category: rule` for clear permanent rules
3. **Repeated pattern** — Same workaround needed across multiple sessions → promote

### PRUNE — Keep Memory Sharp

- **Temp**: Cleared at conversation end
- **Long-term**: Only remove when a rule is proven wrong or the project changed
- **Contradictions**: Newer rule overrides older — Scribe archives the old entry

## Memory Index — `.claude/transformers/memory/long-term/index.md`

One-line decision rules grouped by category. Loaded on every command.

```
# Memory Index

## [Category]
- [decision rule as a one-liner]

## [Another Category]
- [rule]
```

The index IS the quick decision guide. Category files have the reasoning.

## The Memory Test

Before saving anything, apply this filter:

| Save? | Example | Why |
|-------|---------|-----|
| YES | "Always pull --rebase before push in this project" | Changes agent behavior |
| YES | "Skip Barricade for pure UI changes — finds nothing" | Changes orchestrator decisions |
| YES | "Run codegen after model changes or builds fail silently" | Prevents repeated failure |
| NO | "This project uses Flutter 3.x with BLoC" | That's project-context.md |
| NO | "auth_service.dart is at lib/services/" | That's discoverable from code |
| NO | "Fixed null pointer in line 42 of user_repo.dart" | That's an activity log entry |
| NO | "Test run found 3 critical issues" | That's a test result, not a rule |

**If it doesn't change a future decision, don't store it.**
