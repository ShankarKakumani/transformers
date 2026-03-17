# Transformers

```
                               ▄▄▄▄▄▄▄▄▄▄▄▄▄
                          ▄████████████████████▄
                ▐█████▌ ████████████████████████ ▐█████▌
                 ██████▄  ▀████▄       ▄████▀  ▄██████
                 ▐████████▄  ▀████▄ ▄████▀  ▄████████▌
                   ███▄▀█████▄  ▀██████▀  ▄█████▀▄███
                   ▐██▀██▄▀████  ▄  ▀  ▄  ████▀▄██▀██▌
                    ███▄▀██▄███  ███▄███  ███▄██▀▄███
                     ▀████▄▀███  ██████  ███▀▄████▀
                    ▄   ▀██████  ██████  ██████▀   ▄
                    ███          ██████          ███
                    ███▄     ▄██ ██████ ██▄     ▄███
                    ██████ ▄████ ██████ ████▄ ██████
                    ██████ █████ ██████ █████ ██████
                    ██████ █████ ██████ █████ ██████
                    ██████ █████▄▄▄▄▄▄▄█████ ██████
                    ▀█████ ███████████████████ █████▀
                      ▀███ ████  ▄▄▄▄▄  ████ ███▀
                          ▀███▌▐███████▌▐███▀
                               ████████████

                ╔══════════════════════════════════════════╗
                ║  MULTI-AGENT ORCHESTRATION.              ║
                ║  FOR CODE THAT MATTERS.                  ║
                ╚══════════════════════════════════════════╝
```

**A Claude Code plugin that gives you a full engineering team — not a smarter autocomplete.**

14 specialized agents. 2 orchestrators. Every feature goes through requirements, planning, parallel execution, code review, and multi-angle testing. Not because it's fancy. Because that's how good software gets built.

---

## The Problem

Claude Code is brilliant. But brilliant alone isn't a process.

You ask it to build a feature. It writes code. Maybe it's right. Maybe it forgot the edge cases. Maybe it didn't check what else depended on that function. Maybe it skipped the tests. You won't know until something breaks.

Transformers adds what's missing: **structure, specialization, and accountability.**

---

## What You Actually Get

**A real development cycle — not a chat.**

Every feature starts with requirements and a definition of done. Every plan gets your approval before a single line is written. Every build goes through code review and testing before it's called done. You stay the architect. The agents do the work.

**Specialists, not a generalist wearing hats.**

Bumblebee thinks about users. Ironhide thinks about performance. Ratchet thinks about data integrity. Barricade thinks like an attacker. The same Claude model, trained to think differently — because different problems need different instincts.

**Parallel execution that actually works.**

Independent tasks run simultaneously across multiple agents. Optimus decomposes the work, identifies what can run in parallel, and coordinates the results. What would take 10 sequential steps takes 3.

**Memory that survives.**

Agents accumulate decision rules per project across sessions. "Always pull before push here — CI auto-bumps versions." "Skip Barricade for pure UI changes." The plugin gets smarter the more you use it. Other tools forget everything when the context resets.

**Git handled properly.**

GitMaster owns all things git — worktrees for isolation, branching strategy, rebase vs merge decisions, conflict resolution, PR review. Not an afterthought. A specialist.

**Work that survives context limits.**

Every phase writes to artifact files. If Claude Code compacts or you close the terminal, nothing is lost. Resume exactly where you left off.

---

## Quick Start

```bash
# Install (one-time)
/plugin marketplace add ShankarKakumani/transformers
/plugin install transformers@transformers

# Initialize your project (run once per repo)
/transformers:init

# Build a feature — full lifecycle
optimus, build a search bar with filters

# Fix a bug — gather, investigate, fix, verify
optimus, bugfix login fails after password reset

# Test from every angle
megatron, test the auth flow

# Git operations
gitmaster, review this PR
gitmaster, set up worktrees for the payment feature
```

---

## Commands

### Lifecycle Commands

Full development cycle. Artifact tracking, approval gates, persistent state, resumable after compaction.

| Command | What it does |
|---------|-------------|
| `/transformers:feature` | Requirements → research → plan → build → review → test |
| `/transformers:bugfix` | Gather → investigate → fix plan → fix → verify |

### Standalone Commands

Use independently or alongside lifecycle work.

| Command | What it does |
|---------|-------------|
| `/transformers:brainstorm` | Explore approaches and tradeoffs before committing to one |
| `/transformers:research` | Deep codebase or topic exploration — no code changes |
| `/transformers:explain` | Understand code you didn't write, layered from overview to deep dive |
| `/transformers:refactor` | Prowl audits for smells, Autobots fix what you approve |
| `/transformers:debug` | Jazz solo — fast, creative debugging without orchestration overhead |
| `/transformers:test` | Megatron deploys Decepticons for multi-angle test assault |
| `/transformers:pr-generator` | Auto-detects platform, account, branch. Reviews before submitting |
| `/transformers:commit-generator` | Generates commit message for staged files |
| `/transformers:report` | Activity summary — today, this week, or custom range |
| `/transformers:init` | Analyze project, generate context for all agents |

---

## How It Works

### Feature Lifecycle

```
optimus, build a search bar

  Phase 0  Gather         Requirements. Definition of done. Existing resources.
     |
  Phase 1  Research       Autobots explore the codebase from multiple angles — in parallel
     |     GATE ───────▶  You confirm understanding before anything is planned
     |
  Phase 2  Plan           Architecture decisions. Chunk decomposition. Risk assessment.
     |     GATE ───────▶  You approve the plan before a single line is written
     |
  Phase 3  Build          Autobots execute in parallel per the approved plan
     |     GATE ───────▶  You review what was built
     |
  Phase 4  Review + Test  Prowl reviews code quality. Decepticons attack from 4 angles.
     |     GATE ───────▶  You decide on findings
     |
  Phase 5  Summary        What was built. Decisions made. Patterns stored in memory.
```

Every phase writes to `.claude/transformers/active/`. Context compacted? Terminal closed? Resume exactly where you left off.

### Bugfix Lifecycle

```
optimus, bugfix users can't login after SSO

  Phase 0  Gather         Bug details. Logs. Screenshots. When did it start?
     |
  Phase 1  Investigate    Jazz traces symptoms to root cause. Calls backup if needed.
     |     GATE ───────▶  You confirm the root cause before any fix is attempted
     |
  Phase 2  Fix Plan       Proposed fix. Blast radius. Rollback strategy.
     |     GATE ───────▶  You approve the approach
     |
  Phase 3  Fix            Right Autobot executes the fix
     |     GATE ───────▶  You review the fix
     |
  Phase 4  Verify         Prowl reviews. Decepticons confirm the bug is gone.
     |
  Phase 5  Summary        Root cause. What was fixed. Decision rule stored in memory.
```

---

## The Roster

### 🛡️ Autobots — Build Team

| Agent | Specialization |
|-------|---------------|
| **Optimus Prime** | Strategic leader. Decomposes work, delegates to specialists, coordinates results. Never writes code. |
| **Bumblebee** | UI and UX. Thinks from the user's perspective first. Catches what backend engineers miss. |
| **Ironhide** | Backend, APIs, performance. Blunt, direct, shortest path to working code. |
| **Ratchet** | Data layer and migrations. Paranoid about integrity. Never touches prod data carelessly. |
| **Wheeljack** | DevOps, CI/CD, automation. If it can be automated, it should be. |
| **Jazz** | Debugging and hotfixes. Cool under pressure. Creative where others get stuck. |
| **Prowl** | Code review. Read-only. Judges code against the project's own patterns — not generic best practices. |
| **GitMaster** | All things git. Worktrees, branching, rebase, conflict resolution, PR review. The repo's institutional memory. |

### 💥 Decepticons — Test Team

| Agent | Specialization |
|-------|---------------|
| **Megatron** | Test commander. Deploys testers from every angle. Never tests himself. |
| **Soundwave** | Unit tests. Every edge case, every boundary, every null. Thorough to the point of paranoia. |
| **Shockwave** | Integration tests. Does A talk to B correctly? What happens when B is down? |
| **Starscream** | End-to-end tests. Simulates real user journeys. Finds where the complete experience breaks. |
| **Barricade** | Security. Thinks like an attacker. Injection, auth bypass, data leaks, OWASP top 10. |

> You control the model. Assign whatever Claude model you want to each agent — defaults are sensible, but the choice is yours.

---

## What Gets Remembered

Transformers keeps a memory per project — not a cache, a decision rulebook.

```
.claude/transformers/
├── memory/
│   ├── long-term/        ← decision rules that survive across sessions
│   │   ├── index.md      ← loaded on every command (one-liners per rule)
│   │   └── git-workflow.md, testing-strategy.md, ...
│   └── temp.md           ← learnings from the current session
└── active/               ← in-progress feature/bugfix artifacts
```

Examples of what gets remembered:
- "Always pull --rebase before push — CI auto-bumps package versions"
- "Skip Barricade for pure UI changes — it finds nothing and wastes tokens"
- "Run codegen after model changes or builds fail silently"

The index loads on every command. Agents apply relevant rules automatically. You never have to repeat yourself.

---

## Core Principles

Every agent is bound by these — no exceptions:

1. **Human is the architect** — agents build, you decide. Always.
2. **Never fake it** — no stubs, no placeholders, no guessing presented as fact
3. **Impact before action** — check blast radius before changing any interface
4. **Research before guessing** — web search, changelogs, actual error messages first
5. **Security always** — no hardcoded secrets, no unvetted dependencies, no silent failures
6. **Context discipline** — protect the context window, checkpoint to files, resume cleanly
7. **Verify before done** — every builder runs a pre-completion checklist before calling it finished

---

## Installation

```bash
/plugin marketplace add ShankarKakumani/transformers
/plugin install transformers@transformers
```

Then run `/transformers:init` once in your project to generate context for all agents.

### Update
```bash
claude plugin update transformers@transformers
```

### Uninstall
```bash
claude plugin uninstall transformers@transformers
```

### Troubleshooting
```bash
rm -rf ~/.claude/plugins/cache/transformers
/plugin marketplace remove transformers
/plugin marketplace add ShankarKakumani/transformers
/plugin install transformers@transformers
```

### Local development
```bash
claude --plugin-dir ~/path/to/transformers/plugins/transformers
```

---

## Who This Is For

Transformers is for developers doing **serious, multi-phase work** on Claude Code.

If you're making quick edits, fixing typos, or asking Claude to explain a function — you don't need this. Claude Code handles that fine on its own.

If you're building features from scratch, debugging complex issues across multiple systems, or need your AI to not forget what it learned last session — this is built for you.

---

*The Autobots are ready. Are you?*
