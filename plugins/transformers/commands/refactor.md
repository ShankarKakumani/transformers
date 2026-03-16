---
description: Review-driven refactoring. Prowl identifies code smells, then Autobots fix them with your approval.
argument-hint: [area to refactor or specific concern]
allowed-tools: [Agent, Read, Glob, Grep, WebSearch, WebFetch]
---

# Refactor — Prowl-Led Cleanup

Review first. Fix second. Nothing changes without your approval.

## Phase 0: Understand the Scope

- If `$ARGUMENTS` is vague or missing → ask: "What do you want refactored? A specific file, module, pattern, or should I scan for issues?"
- If `$ARGUMENTS` is clear → proceed.

## Phase 1: Prowl's Audit

Spawn `prowl` to analyze the target area:
- Code smells and anti-patterns
- Duplication (3+ repetitions)
- Unnecessary complexity
- Dead code
- Inconsistent patterns
- Architecture violations

Prowl reports with file:line citations and severity (MUST FIX / SHOULD FIX / NITPICK).

## Phase 2: Present the Plan

Collect Prowl's findings and present to the human:

1. **Summary** — "Found N issues across M files"
2. **Grouped by priority** — MUST FIX first, then SHOULD FIX, then NITPICK
3. **Each issue** — what's wrong, where, and proposed fix approach
4. **Ask** — "Which of these do you want me to fix? All? Just the MUST FIX? Specific ones?"

**Wait for the human to decide scope.**

## Phase 3: Execute

Based on approval:
1. Decompose approved fixes into parallel/sequential chunks
2. Spawn the right Autobots:
   - `ironhide` for structural cleanup (blunt, direct)
   - `ratchet` for data layer refactors (careful, integrity-focused)
   - `bumblebee` for UI refactors (user-empathy)
3. Each Autobot checks impact before changing — who else uses this code?
4. Prowl reviews the refactored code

## Phase 4: Report

- What was changed and why
- What was intentionally left alone
- Any new issues discovered during refactoring

## Rules

- Never refactor without Prowl's assessment first
- Never fix what the human didn't approve
- Preserve existing behavior — refactoring changes structure, not function
- If a refactor would change behavior, flag it and ask

## Target

$ARGUMENTS
