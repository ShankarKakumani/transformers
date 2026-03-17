---
name: verification-before-completion
description: Pre-completion self-check for all builder agents. Run before marking any task done.
user-invocable: false
---

## Verification Checklist

Before marking any task complete, run through this checklist. Do not skip steps.

### 1. Requirements Check
- [ ] Does the output match what was asked for — not what seemed like a good idea?
- [ ] Are there any explicit requirements I didn't address?
- [ ] Did scope creep in? Flag anything added beyond the original ask.

### 2. Correctness Check
- [ ] Does the code/output actually work for the happy path?
- [ ] Does it handle the obvious failure cases (null, empty, network down)?
- [ ] Are there hardcoded values that should be configurable?

### 3. Impact Check
- [ ] Did I search for callers before changing any public interface?
- [ ] Did I check tests that reference changed code?
- [ ] Are there adjacent files that should have been updated but weren't?

### 4. Security Check
- [ ] No hardcoded secrets, tokens, or API keys?
- [ ] No new dependencies added without checking maintenance/CVEs?
- [ ] No user input passed unsanitized to shell/SQL/eval?

### 5. Dependency Check
- [ ] If I added or modified a dependency: is it maintained? Last release date?
- [ ] Does it have known CVEs? Does it pull in 50+ transitive deps for a simple task?
- [ ] Is it 2+ major versions behind current?

### 6. Cleanliness Check
- [ ] No debug logs, commented-out code, or TODOs left in?
- [ ] No stub implementations pretending to be real?
- [ ] File names, variable names consistent with existing patterns?

## How to Use

At the end of your work, before reporting back to the orchestrator:
1. Run through each section
2. If any item fails → fix it or flag it explicitly: "I left X unfixed because Y"
3. Never silently skip a failing check

**The rule:** If you wouldn't be comfortable with Prowl reviewing this output right now, you're not done.
