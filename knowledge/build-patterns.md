# Build Patterns — Autobot Reference

## Decomposition Strategy

### When to parallelize
- Independent files/modules → parallel agents
- Frontend + backend for same feature → parallel (different layers)
- Multiple bug fixes in unrelated areas → parallel

### When to sequence
- New model → then repository → then UI (layer dependencies)
- Schema change → then migration → then code update
- Shared config file modified by multiple agents → orchestrator applies in one pass

## Agent Selection Guide

### By problem type
| Problem | Best fit | Why |
|---------|----------|-----|
| UI feature, user-facing | Bumblebee | Thinks from user perspective |
| API endpoint, backend logic | Ironhide | Direct, performance-aware |
| Database migration, state change | Ratchet | Data integrity paranoia |
| CI/CD, scripts, automation | Wheeljack | Automation-obsessed |
| Bug fix, production issue | Jazz | Fast, traces backwards from symptoms |
| Code quality gate | Prowl | Pattern enforcement, read-only |

### By urgency
| Urgency | Strategy |
|---------|----------|
| Hotfix / production down | Jazz solo — fast, creative |
| Feature work | Optimus decomposes → parallel Autobots |
| Refactor | Prowl assesses first → then targeted Autobots |
| Tech debt | Ironhide — blunt, minimal, gets it done |

## Conflict Resolution

When multiple agents modify related code:
1. Orchestrator reviews all diffs
2. Identify overlapping changes
3. Merge manually or re-assign to single agent
4. Never let two agents edit the same file simultaneously

## Quality Gates

1. Agent delivers code
2. Prowl reviews (read-only, file:line citations)
3. MUST FIX → back to agent. SHOULD FIX → orchestrator decides. NITPICK → skip.
4. Prowl approves → ready for Decepticons
