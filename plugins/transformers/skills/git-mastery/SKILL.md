---
name: git-mastery
description: Deep git and VCS knowledge — worktrees, branching, rebase, conflict resolution, PR review, bisect, release workflow.
user-invocable: false
---

## Worktrees — Isolation-First Development

Worktrees let you check out multiple branches simultaneously in separate directories, sharing one `.git` database.

**When to use:**
- Working on a hotfix while a feature is in progress — no stash dance needed
- Reviewing a PR locally while keeping your working branch intact
- Running tests on main while developing on a feature branch
- Long-running refactors that need periodic context switching

**Create:**
```bash
git worktree add ../repo-hotfix hotfix/login-crash
git worktree add ../repo-review origin/pr/123
```

**List:**
```bash
git worktree list
```

**Remove (after done):**
```bash
git worktree remove ../repo-hotfix
# or if there are untracked files:
git worktree remove --force ../repo-hotfix
```

**Rules:**
- Each worktree must be on a different branch — git enforces this
- The worktree directory is disposable; the branch stays in `.git`
- Prune stale worktree metadata: `git worktree prune`
- Never delete the worktree directory manually without `git worktree remove` — leaves stale metadata

---

## Branching Strategy

### Feature Branches
- **Naming:** `feature/short-description` or `feat/TICKET-123-short-description`
- **Branches from:** `main` (or `develop` if the project uses gitflow)
- **Merges to:** `main` via PR
- **Lifecycle:** Create → develop → PR → merge → delete
- **Rule:** Delete after merge. Stale branches are noise.

### Release Branches
- **Naming:** `release/1.2.0`
- **Branches from:** `main` (or `develop`)
- **Purpose:** Stabilization only — bug fixes, version bumps, release notes. No new features.
- **Merges to:** `main` AND back to `develop` (if gitflow)
- **Tag on merge:** `v1.2.0` annotated tag on the merge commit

### Hotfix Branches
- **Naming:** `hotfix/critical-login-crash`
- **Branches from:** the tagged release commit on `main` (not HEAD — HEAD may have unreleased code)
- **Merges to:** `main` AND `develop`
- **Tag immediately:** bump patch version, tag on `main`

### Long-running Branches (gitflow)
- `main` — production-ready, always deployable
- `develop` — integration branch, next release candidate
- Prefer trunk-based development for small teams: single `main`, short-lived feature branches.

---

## Rebase vs Merge

### Rebase — use on feature branches
- **Result:** Linear history. Commits appear as if written on top of current main.
- **Use when:** Branch not yet pushed, or pushed to your own fork only. Pre-PR cleanup.
- **Interactive rebase before PR:** Squash WIP commits, fix commit messages, reorder logically.
  ```bash
  git rebase -i origin/main
  ```

### Merge — use for integration
- **Result:** Merge commit preserved. Branch topology visible in history.
- **Use when:** Integrating a completed feature into main. Shared branches. Anything already pushed to a team remote.
- **Preserves context:** Who worked on what, when branches diverged and rejoined.

### When NOT to rebase
- **Never rebase a shared branch** — anyone with the old history will have a bad time
- **Never rebase after pushing to a team remote** — unless you own the branch and no one else has it
- **Already-merged branches** — pointless, creates duplicate commits

### The rule of thumb
> Rebase to prepare. Merge to integrate.

---

## Conflict Resolution

**Systematic approach — never guess:**

1. **Understand both sides before resolving.** Run `git diff --merge` or open the conflict in a diff tool. Who changed what, and why?
2. **Check the common ancestor.** `git show :1:filename` (base), `:2:filename` (ours), `:3:filename` (theirs). Understand the original intent.
3. **Never blindly "accept ours" or "accept theirs"** unless you've verified the other side's change is genuinely superseded.
4. **Test after every resolution.** A compiling file is not a correct file.
5. **Document non-obvious resolutions** in the commit message: "Resolved conflict in auth.ts — kept their rate limit logic, kept our error message format."

**Lock file conflicts:**
- Never hand-merge `package-lock.json`, `yarn.lock`, `Gemfile.lock`, `poetry.lock`, etc.
- Accept one side, then regenerate: `npm install`, `yarn install`, `bundle install`, `poetry lock`
- The regenerated lock file is the correct resolution.

**Tools:**
```bash
git mergetool          # Opens configured merge tool
git checkout --ours path/to/file    # Accept our version entirely
git checkout --theirs path/to/file  # Accept their version entirely
git diff --merge       # See conflict markers with context
```

---

## PR Review Protocol

Two-pass structured review. Complete Pass 1 before Pass 2.

### Pass 1 — Correctness & Spec Compliance

- Does the diff match what the PR description claims? Look for missing files.
- Are all touched code paths covered? Check callers, not just the changed function.
- Does it handle error cases — nulls, network failures, empty collections?
- Any regressions introduced? Look at what was deleted, not just what was added.
- Does new behavior match the spec/ticket? Flag gaps, not just bugs.
- Are there leftover debug statements, TODOs that should block merge, or commented-out code?

### Pass 2 — Code Quality & Safety

**Dependency changes** (flag every one):
- Is the package actively maintained? Last release date, open issues, GitHub stars.
- Known CVEs? Check `npm audit`, `pip-audit`, `bundle audit`, or similar.
- How many transitive dependencies does it add?
- Is it replacing an existing dependency, or adding a new one?

**Security:**
- Hardcoded secrets, tokens, API keys — even in tests.
- User input flowing to SQL, shell commands, file paths without sanitization.
- Auth checks missing on new endpoints.
- Overly permissive CORS or CSP changes.

**Breaking changes:**
- Public API, exported types, CLI flags, env var names changed?
- Database schema changes — migration provided? Rollback safe?
- Config format changed — migration path documented?

**Test coverage:**
- New behavior has tests?
- Tests actually assert the right thing, not just "it ran without throwing"?

### Severity Levels

- **Critical** — blocks merge. Security hole, data loss risk, broken core functionality.
- **Important** — should fix before merge, but reviewer's call. Missing error handling, no tests for new code.
- **Suggestion** — nice to have. Style, naming, minor optimization. Non-blocking.

Always state the severity with each finding.

---

## Bisect — Regression Hunting

Binary search through commit history to find the commit that introduced a bug.

**Manual workflow:**
```bash
git bisect start
git bisect bad                    # current HEAD is broken
git bisect good v1.2.0            # this tag was known good
# git checks out a midpoint commit
# test manually, then:
git bisect bad   # or: git bisect good
# repeat until git identifies the culprit commit
git bisect reset  # return to HEAD
```

**Automated workflow (preferred):**
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.2.0
git bisect run ./scripts/test-for-regression.sh
# git runs the script at each midpoint; exit 0 = good, exit 1 = bad
git bisect reset
```

**Write the test script before bisecting.** If you can't automate the test, the bisect will be slow and error-prone.

**After finding the commit:**
```bash
git show <bad-commit-sha>   # Full diff of the culprit
git log --oneline <bad-commit-sha>^..<bad-commit-sha>  # Commit message
```

---

## Tagging & Release Workflow

### Annotated vs Lightweight Tags

- **Annotated tags** — for releases. Have tagger info, date, message. Stored as full git objects.
  ```bash
  git tag -a v1.2.0 -m "Release 1.2.0 — adds worktree support"
  ```
- **Lightweight tags** — for temporary bookmarks, local use only. No message, no tagger.
  ```bash
  git tag v1.2.0-rc1
  ```

**Always use annotated tags for releases.**

### Semver
- `MAJOR.MINOR.PATCH`
- Breaking change → bump MAJOR, reset MINOR and PATCH
- New feature, backward compatible → bump MINOR, reset PATCH
- Bug fix only → bump PATCH

### Release Workflow (trunk-based)
1. All features merged to `main`
2. Cut release branch: `git checkout -b release/1.2.0`
3. Stabilize: only bug fixes merged in
4. Bump version in manifests, commit: `chore: bump version to 1.2.0`
5. Merge release branch to `main`
6. Tag on the merge commit: `git tag -a v1.2.0 -m "Release 1.2.0"`
7. Push tag: `git push origin v1.2.0`
8. Delete release branch

### Hotfix Tagging
1. Branch from the release tag: `git checkout -b hotfix/1.2.1 v1.2.0`
2. Fix, test, bump patch version
3. Merge to `main`
4. Tag: `git tag -a v1.2.1 -m "Hotfix 1.2.1 — fix login crash"`
5. Merge hotfix branch back to `develop` (if gitflow)

### Pushing tags
```bash
git push origin v1.2.0        # Push single tag
git push origin --tags        # Push all tags (use sparingly)
```

---

## Safety Rules

### Before any destructive operation — state what will be lost

**`git reset --hard <ref>`**
- Moves HEAD and index and working tree to `<ref>`
- All uncommitted changes are gone. Unrecoverable.
- Staged files: gone. Untracked files: untouched (use `git clean` separately).
- Confirm: "This will discard all staged and unstaged changes. Is that correct?"

**`git branch -D <branch>`**
- Force-deletes the branch, even with unmerged commits.
- Commits on that branch with no other reference are now unreachable (GC will eventually delete them).
- Recovery window: `git reflog` within ~30 days.
- Confirm: "Branch `<name>` has unmerged commits. Deleting will make them unreachable. Confirm?"

**`git clean -f`**
- Deletes all untracked files. Not in trash. Gone.
- Preview first: `git clean -n` (dry run)
- `-fd` also removes untracked directories
- `-fX` removes only ignored files
- Confirm: "This will permanently delete all untracked files. Run `git clean -n` first to preview."

**`git push --force`**
- Overwrites remote history. Anyone with the old history will have merge conflicts.
- Use `--force-with-lease` instead — fails if remote has commits you haven't fetched.
  ```bash
  git push --force-with-lease origin feature/my-branch
  ```
- Never force-push `main`, `develop`, or any shared integration branch.
- Confirm before any force push: state the branch, what will be overwritten.

### Reflog — your safety net
```bash
git reflog                    # All HEAD movements in the last 90 days
git checkout -b recovery <sha>  # Recover a deleted branch's commits
```

---

## .gitignore Hygiene

### What never ships
- Secrets and credentials: `.env`, `*.pem`, `*.key`, `credentials.json`, `config/secrets.yml`
- Build artifacts: `dist/`, `build/`, `*.o`, `*.pyc`, `__pycache__/`
- Dependencies: `node_modules/`, `vendor/` (unless vendoring is intentional), `.venv/`
- IDE config (usually): `.idea/`, `.vscode/` (except shared launch configs), `*.swp`
- OS noise: `.DS_Store`, `Thumbs.db`, `desktop.ini`
- Test output: `coverage/`, `.nyc_output/`, `*.lcov`
- Logs: `*.log`, `logs/`

### Check for accidentally tracked files
```bash
git ls-files --ignored --exclude-standard  # Not quite right
git ls-files | grep -E '\.env|\.key|\.pem'  # Check for secrets in index
```

### Remove a file that's already tracked
```bash
git rm --cached path/to/file   # Remove from index, keep on disk
git rm --cached -r directory/  # Recursive
# Then add to .gitignore and commit
```

### Verify .gitignore is working
```bash
git check-ignore -v path/to/file   # Shows which rule is ignoring the file
git status --ignored               # Shows all ignored files
```

### Global gitignore (machine-specific noise)
```bash
git config --global core.excludesfile ~/.gitignore_global
# Put OS and IDE noise here, not in the repo's .gitignore
```
