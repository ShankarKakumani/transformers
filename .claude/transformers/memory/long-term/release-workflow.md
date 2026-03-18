---
type: long-term
topic: release-workflow
source: init (2026-03-18)
---

# Release Workflow

- Always `git pull` after pushing a tag. CI auto-commits `chore: bump version to X.Y.Z` back to `main` after every tag push — your local will be behind without a pull.
- Release sequence: `git tag -a vX.Y.Z -m "..."` → `git push origin main` → `git push origin vX.Y.Z` → wait for CI → `git pull`
- Never manually edit version files after a tag push — CI will overwrite them.
