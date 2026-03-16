---
description: Ship your code. Auto-detects branch, remembers reviewers, reviews before submitting.
argument-hint: [optional: any context about the PR]
allowed-tools: [Agent, Read, Glob, Grep, Bash, WebSearch, WebFetch]
---

# Pull Request — Smart Submission

Generate a quality PR with the least friction possible.

## HARD RULES

1. **NEVER use `subagent_type: Explore`, `Plan`, or `general-purpose`**. Reviews go through `prowl` and `barricade`.
2. **Never create a PR without explicit user approval.**
3. **Never skip the security scan.**

## Phase 0: Gather Context Automatically

Do all of this BEFORE asking the user anything:

1. **Current branch**: `git branch --show-current`
2. **Detect parent branch**: `git log --oneline --decorate --first-parent` — figure out which branch this was checked out from (usually `main`, `develop`, or a feature branch)
3. **Check for uncommitted changes**: `git status`
4. **Get the diff**: `git log <parent>..HEAD --oneline` to see all commits
5. **Check if gh CLI is available**: `which gh` — this determines our workflow
6. **Check for stored reviewers**: Look in project memory for previously used reviewers

## Phase 1: Confirm with the User

Present what you found and ask:

"Here's what I see:
- **Current branch**: `feature/xyz`
- **Looks like you branched from**: `main` (based on git history)
- **Commits**: N commits with [brief summary]
- **Uncommitted changes**: yes/no
- **gh CLI**: available/not available
- **Previous reviewers**: @person1, @person2 (if stored in memory)

**Target branch**: `main` — is that right, or do you want a different target?
**Reviewers**: Want to add @person1, @person2 again? Or different ones?
**Uncommitted changes**: Want me to commit these first?"

**Wait for answers.**

## Phase 2: Review the Changes

Spawn agents in parallel:

### Prowl — Code Quality
Review all changes in the diff for pattern violations, quality issues.

### Barricade — Security Scan
Scan for hardcoded secrets, injection risks, auth issues.

Present findings:
- If CRITICAL issues → "These should be fixed before submitting. Want me to fix them?"
- If clean → proceed

**Wait for approval if issues found.**

## Phase 3: Generate Title & Summary

Based on the diff and commits, draft:
- **Title**: concise, under 70 chars, describes the what
- **Summary**:
  - What changed and why (2-3 bullets)
  - Key files modified
  - Breaking changes (if any)

Present to user: "Here's the PR I'd create. Want to edit anything?"

**Wait for approval.**

## Phase 4: Submit

### If gh CLI is available:
```
gh pr create --base <target> --title "..." --body "..."
```
Add reviewers if specified:
```
gh pr edit <number> --add-reviewer reviewer1,reviewer2
```

### If gh CLI is NOT available:
"gh CLI isn't available. Here's your PR ready to copy:

**Title**: ...

**Summary**:
...

**Target branch**: ...

Create it manually or install gh CLI (`brew install gh`) for automated PRs."

## Phase 5: Remember

Store in project memory:
- Reviewers used (so we can suggest them next time)
- Target branch pattern (if non-standard)

## Rules

- Never create the PR without explicit user approval
- Never assume the target branch — verify and confirm
- Never skip the security scan
- If there are uncommitted changes, ask before committing
- Always present the title and summary for review before submitting
- Remember reviewers for next time

## Context

$ARGUMENTS
