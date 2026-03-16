---
description: Quality PR generator. Prowl reviews the diff, Barricade scans for security, Optimus writes the summary.
argument-hint: [optional: base branch, default main]
allowed-tools: [Agent, Read, Glob, Grep, Bash, WebSearch, WebFetch]
---

# PR — Quality Pull Request

Generate a production-ready PR with automated review and security scan.

## Phase 0: Check State

1. Run `git status` — are there uncommitted changes? If yes, ask: "You have uncommitted changes. Want me to commit first, or just PR what's already committed?"
2. Run `git log main..HEAD` — what commits are we PR-ing?
3. If no commits differ from base → "Nothing to PR. You're up to date with main."

## Phase 1: Parallel Review

Spawn three agents simultaneously:

### Prowl — Code Review
Review all changes in the diff:
- Pattern consistency
- Architecture adherence
- Code quality
- file:line citations for issues

### Barricade — Security Scan
Scan the diff for:
- Hardcoded secrets or credentials
- Injection vulnerabilities
- Auth/authorization issues
- Dangerous package additions

### Bumblebee — User Impact
Assess from the user's perspective:
- What does this change DO for the user?
- Any UX implications?
- Breaking changes?

## Phase 2: Report Findings

Present all findings to the human:
- **Prowl**: Code quality issues (MUST FIX / SHOULD FIX / NITPICK)
- **Barricade**: Security concerns (CRITICAL / HIGH / MEDIUM / LOW)
- **Bumblebee**: User impact summary

If MUST FIX or CRITICAL items exist → "These should be fixed before merging. Want me to fix them?"

**Wait for approval before creating the PR.**

## Phase 3: Generate PR

Using `gh pr create`:

1. **Title** — concise, under 70 chars, describes the what
2. **Body** — structured:
   - Summary (2-3 bullets of what and why)
   - Changes (key files and what changed)
   - Test plan (what to verify)
   - Security review: passed/flagged items
   - Breaking changes (if any)
3. Push branch if needed
4. Create the PR

## Rules

- Never create the PR without human approval
- Never skip the security scan
- If Barricade finds a CRITICAL issue, block PR creation until resolved
- Respect the project's PR conventions if they exist in CLAUDE.md
- Don't add reviewers unless the human asks

## Base Branch

$ARGUMENTS
