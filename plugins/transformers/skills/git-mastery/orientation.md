### Section: Repo Orientation Protocol

A standard sequence to run at the start of every git session to understand the terrain:

```bash
# 1. Current state
git status

# 2. Branch topology — tracking info, ahead/behind
git branch -vv

# 3. Remote topology
git remote -v

# 4. Recent history shape
git log --oneline --graph --decorate -15

# 5. Stashed work
git stash list

# 6. Existing tags (detect version pattern)
git tag --sort=-version:refname | head -10

# 7. OS detection
uname -s   # Darwin = macOS, Linux = Linux, MINGW/CYGWIN = Windows
```

---

### Section: OS Adaptation

Git behaviour differs across platforms. Detect and adapt.

**Detect OS:**
```bash
uname -s
# Darwin → macOS
# Linux → Linux
# MINGW64_NT / CYGWIN → Windows (Git Bash)
```

**macOS specifics:**
- `.DS_Store` — always in `.gitignore`. Check with `git ls-files --others --ignored --exclude-standard | grep DS_Store`
- Credential helper: `git config --global credential.helper osxkeychain`
- Case-insensitive filesystem — `file.txt` and `FILE.txt` are the same file. Renames can silently fail.
  ```bash
  git config core.ignorecase false  # Detect case-only renames
  ```
- File permissions on hooks: `chmod +x .git/hooks/pre-commit`

**Linux specifics:**
- Credential helper: `git config --global credential.helper store` (or `libsecret` on desktop)
- File permission issues are common on hooks — always `chmod +x` after creating
- Symlinks preserved; on macOS they're also fine; on Windows they require extra config

**Windows (Git Bash / WSL) specifics:**
- Line endings: `git config --global core.autocrlf true` (Windows) or `input` (cross-platform)
- Path length limit: Windows MAX_PATH = 260 chars. Enable long paths:
  ```bash
  git config --global core.longpaths true
  # Also requires Windows registry change: HKLM\SYSTEM\...\FileSystem\LongPathsEnabled = 1
  ```
- Symlinks: require Developer Mode or admin rights. `git config --global core.symlinks false` as fallback.
- Credential helper: `git config --global credential.helper manager-core` (Git Credential Manager)
- Shell differences: use `Git Bash` or `WSL2` — avoid `cmd.exe` for git operations
- `.gitconfig` location: `C:\Users\<name>\.gitconfig`

---

### Section: Tag Pattern Detection

Before creating a tag, read the project's existing tag conventions.

**Read existing tags:**
```bash
git tag --sort=-version:refname | head -20
```

**Infer pattern from output:**
- `v1.2.3`, `v2.0.0` → semver with `v` prefix: `vMAJOR.MINOR.PATCH`
- `1.2.3`, `2.0.0` → semver without prefix: `MAJOR.MINOR.PATCH`
- `release-1.2.3` → named prefix: `release-MAJOR.MINOR.PATCH`
- `app/v1.2.3`, `api/v2.1.0` → monorepo pattern: `<component>/vMAJOR.MINOR.PATCH`
- Mixed or no pattern → ask user: "What tag format do you use? I'll remember it."

**Infer next version:**
```bash
git tag --sort=-version:refname | head -3
# If last 3 tags are v1.2.3, v1.2.2, v1.2.1 → patch bumps are typical
# If last 3 tags are v1.3.0, v1.2.0, v1.1.0 → minor bumps are typical
```

**Apply the pattern:** Never create a tag without confirming the next version with the user. Show: "Last tag was `v1.2.3`. Based on your pattern, next patch = `v1.2.4`, next minor = `v1.3.0`. Which?"

**Write to memory:**
```
[LONG-TERM] git-tags: pattern=vMAJOR.MINOR.PATCH, last=v1.2.3, typical-bump=patch
```

---

### Section: Push Behaviour & Upstream Awareness

**Check before every push:**

```bash
# 1. Does the branch have a remote tracking branch?
git branch -vv
# "[ahead 2]" = unpushed commits; "gone" = remote branch was deleted

# 2. What is the push strategy?
git config push.default
# simple (default) = push to matching upstream only
# current = push to branch of same name
# upstream = push to tracked upstream
# matching = push all matching branches (dangerous on old git)

# 3. Is there a remote?
git remote -v

# 4. Any uncommitted changes that should be staged first?
git status --short
```

**Patterns to detect and remember:**

- **CI auto-commit pattern**: After pushing, CI bumps version or updates a lock file and commits to remote. Always pull after push.
  ```
  [LONG-TERM] git-push: CI auto-commits after push — always git pull after git push
  ```
- **Force-push habit**: User regularly force-pushes feature branches after rebase. Normal and fine on personal branches.
  ```
  [LONG-TERM] git-push: user rebases and force-pushes feature branches — expected, not an error
  ```
- **Pull before push**: Project requires `git pull --rebase` before push to avoid merge commits on main.
  ```
  [LONG-TERM] git-push: always pull --rebase before pushing to main
  ```

**Pre-push sequence (learned):**
When user completes a sequence (e.g. pull → rebase → push), store it:
```
[LONG-TERM] git-sequence: pre-push = git pull --rebase origin main && git push
```

---

### Section: Pre-commit Hook Detection

Check for hooks before any commit operation. A slow or broken hook can derail a workflow.

**Where hooks live:**
```bash
# Native git hooks
ls -la .git/hooks/pre-commit

# Husky v4 (old)
ls .huskyrc .huskyrc.json .huskyrc.yaml

# Husky v6+ (new)
ls .husky/pre-commit

# Lefthook
ls lefthook.yml lefthook.yaml

# pre-commit framework (Python)
ls .pre-commit-config.yaml
```

**Check if hook is executable (macOS/Linux):**
```bash
test -x .git/hooks/pre-commit && echo "executable" || echo "NOT executable — hook won't run"
```

**What to tell the user:**
- Hook found + executable → "Pre-commit hook detected (`husky`). It will run before this commit. If it's slow, plan for a wait."
- Hook found + NOT executable → "Pre-commit hook exists but isn't executable. It won't run. Run `chmod +x .git/hooks/pre-commit` to activate it."
- Hook fails during commit → diagnose: show the hook output, identify the failing check, propose fix plan.

**Common hook failures and fixes:**

| Hook failure | Likely cause | Fix |
|---|---|---|
| `lint` failed | Code style violations | Run linter + auto-fix: `eslint --fix`, `ruff --fix`, `gofmt -w` |
| `tests` failed | Broken tests | Run tests, fix failures before committing |
| `secrets detected` | Credential in diff | Remove secret, rotate it, add pattern to `.gitignore` |
| `hook not found` | Hook manager not installed | `npm install` / `pip install pre-commit` |
| `permission denied` | Hook not executable | `chmod +x .git/hooks/pre-commit` (Linux/macOS) |

**Write to memory after first encounter:**
```
[LONG-TERM] git-hooks: pre-commit uses husky, runs eslint+tests (~45s)
```
