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
