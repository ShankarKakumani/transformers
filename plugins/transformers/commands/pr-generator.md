---
description: Generate a PR with review. Auto-detects platform, account, branch. Remembers preferences per project.
argument-hint: [any context about the PR]
allowed-tools: Agent, Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch
---

# PR Generator — Smart Pull Request Creation

Generate a quality PR with the least friction possible. Detect the platform, account, and branch automatically.

## HARD RULES

1. **NEVER use `subagent_type: Explore`, `Plan`, or `general-purpose`**. Reviews go through `prowl` and `barricade`.
2. **Never create a PR without explicit user approval.**
3. **Never skip the security scan.**
4. **Never add Co-Authored-By or any co-author attribution.**

## Phase 0: Detect Environment

Do all of this BEFORE asking the user anything:

### Platform & Account Detection
1. **Check git remote**: `git remote -v` — detect the platform from the URL:
   - `github.com` → GitHub
   - `gitlab.com` or self-hosted GitLab → GitLab
   - `bitbucket.org` → Bitbucket
   - `dev.azure.com` → Azure DevOps

2. **Detect account/org** from the remote URL — extract the owner/org name.

3. **Check CLI availability** based on detected platform:
   - GitHub → `which gh` then `gh auth status` (shows which account is active)
   - GitLab → `which glab` then `glab auth status`
   - If no CLI → we'll generate copy-paste output

4. **Check for multiple accounts** (GitHub):
   - `gh auth status` shows all authenticated accounts
   - Compare the remote's org/owner against authenticated accounts
   - If the active account doesn't match the remote → warn and suggest switching

5. **Check stored preferences**: Read `.claude/transformers/context/pr-preferences.md` if it exists:
   - Last used account for this project
   - Preferred target branch
   - Preferred reviewers
   - PR template preferences

### Branch & Changes Detection
6. **Current branch**: `git branch --show-current`
7. **Detect parent branch**: `git log --oneline --decorate --first-parent`
8. **Check for uncommitted changes**: `git status`
9. **Get the diff**: `git log <parent>..HEAD --oneline` and `git diff <parent>...HEAD`
10. **Check for artifacts**: Look in `.claude/transformers/.temp/features/` or `.claude/transformers/.temp/bugfix/` for related feature/bugfix artifacts

## Phase 1: Confirm with the User

Present what you found and ask:

"Here's what I see:
- **Platform**: GitHub / GitLab / etc.
- **Account**: @username (active on gh/glab CLI)
- **Remote**: org/repo
- **Current branch**: `feature/xyz`
- **Branched from**: `main`
- **Commits**: N commits with [brief summary]
- **Uncommitted changes**: yes/no

**Target branch**: `main` — is that right?
**Account**: Using @username — correct? (if multiple accounts detected, list them)
**Uncommitted changes**: Want me to commit these first?"

If the user switches accounts or overrides any preference → save it for next time.

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

### Fix Critical Issues (if approved)

Spawn the right Autobot to fix each issue:
- `ironhide` for backend/logic fixes
- `bumblebee` for UI fixes
- `jazz` for quick patches

Re-run Prowl on the fixes. Repeat until clean or user says submit anyway.

## Phase 3: Generate Title & Summary

Based on the diff, commits, and any artifacts found in Phase 0:

- **Title**: concise, under 70 chars, describes the what
- **Summary**:
  - What changed and why (2-3 bullets)
  - Key files modified
  - Breaking changes (if any)

Present to user: "Here's the PR I'd create. Want to edit anything?"

**Wait for approval.**

## Phase 4: Submit

### GitHub (gh CLI available):
```
gh pr create --base <target> --title "..." --body "..."
```

### GitLab (glab CLI available):
```
glab mr create --target-branch <target> --title "..." --description "..."
```

### No CLI available:
"No CLI detected for [platform]. Here's your PR ready to copy:

**Title**: ...
**Summary**: ...
**Target branch**: ...
**URL**: [direct link to create PR on the platform if possible]

Install `gh` (GitHub) or `glab` (GitLab) for automated PR creation."

## Phase 5: Remember Preferences

Save to `.claude/transformers/context/pr-preferences.md`:
- Platform detected
- Account used (so we can suggest it next time)
- Target branch used
- Reviewers added (if any)
- Any overrides the user specified

Format:
```markdown
# PR Preferences
Last updated: [date]

## Account
- platform: github
- account: @username
- remote: org/repo

## Defaults
- target_branch: main
- reviewers: @person1, @person2

## History
- [date]: PR #123 → main, account @username
```

## Rules

- Never create the PR without explicit user approval
- Never assume the target branch — verify and confirm
- Never skip the security scan
- If there are uncommitted changes, ask before committing
- Always present the title and summary for review before submitting
- If multiple accounts are detected, always confirm which one to use
- Save preferences after every PR — learn from the user's choices
- If the user says "use my personal account" or "use work account", remember that mapping

## Context

$ARGUMENTS
