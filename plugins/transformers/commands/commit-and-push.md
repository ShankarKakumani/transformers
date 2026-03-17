---
description: Generate commit message, confirm, commit and push. Auto-detects remote, branch, upstream. One approval gate.
argument-hint: [context about the changes]
allowed-tools: Agent, Read, Glob, Grep, Bash
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

2. **Push** — delegate to GitMaster:
   Spawn `gitmaster` with:
   > "Push the current branch. Branch: `<branch>`. Upstream status: `<from Phase 0 detection>`. Platform: `<github/gitlab/etc>`. Apply any known push patterns from memory. Handle hook detection, upstream setup, and any push failures. Return a 1-line result."

   GitMaster handles:
   - Hook detection before push
   - Upstream setup if missing (`git push -u origin <branch>`)
   - Pull --rebase if behind remote
   - Auth failure diagnosis
   - Tag detection if this commit is tagged
   - Writing push patterns to memory

3. **Report**: "Committed and pushed to `origin/<branch>`."

4. **Log**: Spawn Scribe to log activity: "Append to `.claude/transformers/activity.log`: `YYYY-MM-DD HH:MM commit-and-push [commit message summary] [files committed count]`"

## Memory Check

Before starting, read `.claude/transformers/memory/long-term/index.md` if it exists. Check `git-workflow` for learnings about this project's git workflow — pass them to GitMaster in the push delegation so it starts informed.

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
