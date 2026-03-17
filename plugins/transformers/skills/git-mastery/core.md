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
