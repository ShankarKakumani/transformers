---
description: Generate commit message, confirm, commit and push. Auto-detects remote, branch, upstream. One approval gate.
argument-hint: [context about the changes]
allowed-tools: Read, Glob, Grep, Bash
model: sonnet
---

# Commit & Push — One-Shot Commit + Push

Generate a commit message, get approval, then commit and push in one flow.

## HARD RULES

1. **Never commit without user approval of the message.**
2. **Never add Co-Authored-By or any co-author attribution.**
3. **Never use `--amend` unless user explicitly asks.**
4. **Never force push.**

## Phase 0: Detect Environment

Do all of this silently before presenting anything:

1. **Staged changes**: `git diff --cached --stat` — if nothing staged → "Nothing staged. Want me to help you stage files first?"
2. **Current branch**: `git branch --show-current`
3. **Remote & upstream**: `git remote -v` and `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
   - If upstream exists → we'll `git push`
   - If no upstream → we'll `git push -u origin <branch>`
4. **Remote account**: Extract org/owner from remote URL
5. **Platform**: Detect from remote URL (github.com, gitlab.com, etc.)
6. **Auth check** (platform-specific):
   - GitHub → `gh auth status` — confirm active account matches remote org
   - GitLab → `glab auth status`
   - If active account doesn't match remote → warn before proceeding
7. **Uncommitted unstaged changes**: `git status` — note them but don't touch them
8. **Full diff**: `git diff --cached` — read the actual changes

## Phase 1: Analyze & Present

Read the staged diff carefully:
- What changed? (new feature, bug fix, refactor, config, etc.)
- Why? (infer from changes, or use `$ARGUMENTS` if provided)
- What's the scope? (single file, module, cross-cutting)

Generate a commit message:
- **First line**: type + concise summary, under 72 chars
  - `feat:` new feature
  - `fix:` bug fix
  - `refactor:` code restructure
  - `chore:` maintenance, config, deps
  - `docs:` documentation
  - `test:` test changes
  - `style:` formatting, no logic change
- **Body** (only if needed): brief explanation of why, not what

Present everything at once:

```
**Environment**:
- Branch: `feature/xyz` → pushing to `origin/feature/xyz`
- Account: @username on GitHub (org/repo)
- Upstream: tracking / will set up

**Commit message**:
  [message]

**Unstaged changes**: [list if any, or "none"]

Good to commit and push? (yes / edit / abort)
```

**This is the only approval gate. Wait for it.**

## Phase 2: Commit & Push

On approval:

1. **Commit**: `git commit -m "[approved message]"`
   - If commit fails (pre-commit hook, etc.):
     - Read the error
     - Fix the issue
     - Stage the fix
     - Create a NEW commit (never amend)
     - Show the user what was fixed

2. **Push** (immediately after successful commit):
   - Has upstream → `git push`
   - No upstream → `git push -u origin <branch>`
   - If push fails:
     - Behind remote → `git pull --rebase` then retry push, report what happened
     - Auth failure → report and suggest fix
     - Other → report error clearly, suggest fix, wait for approval before retrying

3. **Report**: "Committed and pushed to `origin/<branch>`."

## Rules

- One approval gate — message confirmation covers both commit and push
- Never commit without showing the message first
- Never amend previous commits
- Never force push
- If there are unstaged changes, mention them but don't touch them
- Keep commit messages concise — one line is fine for small changes
- If account mismatch detected, warn before the approval gate (not after)

## Context

$ARGUMENTS
