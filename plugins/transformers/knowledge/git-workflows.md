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

### Section: Stash Workflow

When a worktree isn't appropriate and you need to context-switch quickly.

**Save work:**
```bash
git stash push -m "wip: half-done auth refactor"   # Named stash (always name them)
git stash push --include-untracked -m "wip: new files too"  # Include untracked files
```

**List stashes:**
```bash
git stash list
```

**Restore:**
```bash
git stash pop          # Apply latest, remove from stash list
git stash apply stash@{1}  # Apply specific, keep in list
```

**Inspect before applying:**
```bash
git stash show -p stash@{0}   # Full diff of a stash
```

**Drop stale stashes:**
```bash
git stash drop stash@{1}   # Drop specific
git stash clear             # Drop all (careful)
```

**Rules:**
- Always name your stashes. `git stash push -m "description"` — anonymous stashes are impossible to distinguish after a week.
- If stash list > 3 entries, something went wrong. Use worktrees for parallel work.
- `git stash pop` on a conflicting branch will leave conflict markers — resolve like a merge conflict.
- Untracked files are NOT stashed by default. Use `--include-untracked` if needed.

---

### Section: Cherry-pick

Apply a specific commit from one branch onto another without merging the whole branch.

**Basic usage:**
```bash
git cherry-pick <commit-sha>
git cherry-pick abc1234 def5678   # Multiple commits, in order
git cherry-pick v1.2.0..v1.2.3   # Range (exclusive start)
```

**With edit:**
```bash
git cherry-pick -e <sha>   # Opens editor to modify commit message
```

**No-commit (stage only, don't commit yet):**
```bash
git cherry-pick -n <sha>   # Apply changes, let you review before committing
```

**Conflict during cherry-pick:**
```bash
# Resolve conflicts in the file, then:
git add <resolved-file>
git cherry-pick --continue

# Or abort entirely:
git cherry-pick --abort
```

**Rules:**
- Cherry-pick duplicates commits — the SHA will be different even if the diff is identical. This is expected.
- Avoid cherry-picking large, intertwined commits — prefer small atomic commits that cherry-pick cleanly.
- After cherry-picking to a release branch, the original commit still exists on main. Don't delete it.
- If cherry-picking a range, order matters — pick oldest to newest.

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
