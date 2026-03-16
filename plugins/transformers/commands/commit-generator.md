---
description: Generate commit messages for staged changes. Reviews staged files, generates message, asks to push.
argument-hint: [context about the changes]
allowed-tools: Read, Glob, Grep, Bash
model: sonnet
---

# Commit Generator — Smart Commit Messages

Generate clear, descriptive commit messages for staged changes.

## HARD RULES

1. **Never commit without user approval.**
2. **Never push without user approval.**
3. **Never add Co-Authored-By or any co-author attribution.**
4. **Never use `--amend` unless user explicitly asks.**

## Phase 0: Check Staged Changes

1. Run `git status` to see what's staged
2. If nothing is staged → "Nothing staged. Want me to help you stage files first?"
3. If there are staged changes → run `git diff --cached` to see the actual diff

## Phase 1: Analyze & Generate

Read the diff carefully:
- What changed? (new feature, bug fix, refactor, config change, etc.)
- Why? (infer from the changes, or use `$ARGUMENTS` if provided)
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
- **Body** (if needed): brief explanation of why, not what (the diff shows what)

Present to the user:
```
Here's the commit message I'd use:

  [message]

Want to use this, edit it, or regenerate?
```

**Wait for approval.**

## Phase 2: Commit

Run `git commit -m "[approved message]"`

If the commit fails (pre-commit hook, etc.):
- Read the error
- Fix the issue
- Stage the fix
- Create a NEW commit (never amend)

## Phase 3: Push

After successful commit, ask:

"Committed. Want me to push to remote?"

- If yes → `git push` (or `git push -u origin <branch>` if no upstream)
- If no → done

If push fails (no upstream, rejected, etc.):
- Report the error clearly
- Suggest the fix
- Wait for approval before retrying

## Rules

- Never commit without showing the message first
- Never push without asking
- Never amend previous commits
- Never force push
- If there are unstaged changes alongside staged ones, mention them but don't touch them
- Keep commit messages concise — one line is fine for small changes

## Context

$ARGUMENTS
