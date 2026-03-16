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
                ║     AUTOBOTS BUILD. DECEPTICONS TEST.    ║
                ╚══════════════════════════════════════════╝
```

**AI-powered build and test orchestration for [Claude Code](https://claude.ai/code).**

12 specialized agents. 2 orchestrators. 1 plugin. Your code goes through a proper development cycle — requirements, planning, building, review, and testing — with agents that think differently about every problem.

---

## Why Transformers?

Claude Code is powerful on its own. Transformers adds structure:

- **Proper development cycle** — Every feature starts with requirements, definition of done, and a plan before any code is written
- **Specialized thinking** — Same tools, different perspectives. A security-minded agent catches what a UX-focused agent wouldn't
- **Parallel execution** — Independent tasks run simultaneously across multiple agents
- **Artifact persistence** — Progress is saved to files, surviving context compaction. Resume where you left off
- **Human in the loop** — You're the architect. Agents build, you decide at every gate

---

## Quick Start

```bash
# Install (one-time)
/plugin marketplace add ShankarKakumani/transformers
/plugin install transformers@transformers

# Build a feature (full lifecycle)
/transformers:feature add dark mode support

# Fix a bug (full lifecycle)
/transformers:bugfix login fails after password reset

# Quick debug (Jazz solo, no orchestration)
/transformers:debug null pointer in auth middleware
```

---

## Commands

### Lifecycle Commands

Full development cycle with artifact tracking, human approval gates, and persistent state.

| Command | What it does |
|---------|-------------|
| `/transformers:feature` | Requirements → research → plan → build → review → test |
| `/transformers:bugfix` | Bug details → investigate → fix plan → fix → verify |

### Individual Commands

Standalone tools. Use them independently or as part of your workflow.

| Command | What it does |
|---------|-------------|
| `/transformers:brainstorm` | Explore approaches and tradeoffs with multiple agents |
| `/transformers:research` | Deep codebase or topic exploration, no code changes |
| `/transformers:explain` | Understand code you didn't write, layered from overview to deep dive |
| `/transformers:refactor` | Prowl audits for code smells, Autobots fix what you approve |
| `/transformers:debug` | Jazz solo — fast, creative debugging without orchestration overhead |
| `/transformers:test` | Megatron deploys Decepticons for multi-angle test assault |
| `/transformers:pr-generator` | Auto-detects platform (GitHub/GitLab), account, branch. Reviews before submitting |
| `/transformers:commit-generator` | Generates commit message for staged files, asks before pushing |
| `/transformers:report` | Activity summary — today, this week, or custom range |
| `/transformers:init` | Analyze project and generate context for all agents |

---

## How It Works

### Feature Lifecycle

```
/transformers:feature add a search bar

  Phase 0  Gather         What's the requirement? Definition of done? Existing resources?
     |
  Phase 1  Research        Autobots explore the codebase from multiple angles
     |     GATE ---------> Human confirms understanding
     |
  Phase 2  Plan            Architecture decisions, chunk decomposition, risk assessment
     |     GATE ---------> Human approves the plan
     |
  Phase 3  Build           Autobots execute in parallel per the plan
     |     GATE ---------> Human reviews what was built
     |
  Phase 4  Review + Test   Prowl reviews code quality, Decepticons attack from every angle
     |     GATE ---------> Human decides on findings
     |
  Phase 5  Summary         What was built, decisions made, patterns learned
```

Every phase writes to `.claude/transformers/active/` — if context gets compacted or you close the terminal, the work is preserved and resumable.

### Bugfix Lifecycle

```
/transformers:bugfix users can't login

  Phase 0  Gather         What's the bug? Logs? Screenshots? When did it start?
     |
  Phase 1  Investigate    Jazz traces symptoms to root cause, calls for backup if needed
     |     GATE ---------> Human confirms root cause
     |
  Phase 2  Fix Plan       Proposed fix, blast radius, rollback strategy
     |     GATE ---------> Human approves approach
     |
  Phase 3  Fix            Right Autobot executes the fix
     |     GATE ---------> Human reviews the fix
     |
  Phase 4  Verify         Prowl reviews + Decepticons confirm the bug is gone
     |     GATE ---------> Human approves
     |
  Phase 5  Summary        Root cause, what was fixed, patterns stored
```

---

## The Roster

### Autobots — Build Team

| Agent | Role | Model |
|-------|------|-------|
| **Optimus** | Strategic leader. Decomposes, delegates, never writes code. | Opus |
| **Bumblebee** | UI/UX. Thinks from the user's perspective first. | Sonnet |
| **Ironhide** | Backend, APIs, performance. Shortest path to working code. | Sonnet |
| **Ratchet** | Data layer, migrations. Paranoid about data integrity. | Sonnet |
| **Wheeljack** | DevOps, CI/CD, automation. If it can be automated, it should be. | Sonnet |
| **Jazz** | Debugging, hotfixes. Cool under pressure, creative solutions. | Sonnet |
| **Prowl** | Code review. Read-only. Judges against the project's own patterns. | Sonnet |

### Decepticons — Test Team

| Agent | Role | Model |
|-------|------|-------|
| **Megatron** | Test commander. Deploys testers, never tests himself. | Opus |
| **Soundwave** | Unit tests. Every edge case, boundary, null. | Haiku |
| **Shockwave** | Integration tests. Contracts, failures, timeouts. | Haiku |
| **Starscream** | E2E tests. Full user journeys, flow breakers. | Sonnet |
| **Barricade** | Security tests. Injection, auth bypass, OWASP top 10. | Sonnet |

---

## Core Principles

Every agent follows these rules:

1. **Human is the architect** — agents build, human decides
2. **Never fake it** — no stubs, no placeholders, no guessing presented as fact
3. **Impact before action** — check blast radius before changing anything
4. **Research before guessing** — search the web, check issues, verify
5. **Security first** — no secrets in code, no dangerous packages
6. **Context discipline** — protect the context window, checkpoint early

---

## Installation

```bash
# Add marketplace (one-time)
/plugin marketplace add ShankarKakumani/transformers

# Install
/plugin install transformers@transformers
```

### Update
```bash
claude plugin update transformers@transformers
```

### Uninstall
```bash
claude plugin uninstall transformers@transformers
```

### Troubleshooting
If you get errors after updating:
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

## Plugin Structure

```
transformers/
├── .claude-plugin/marketplace.json
├── plugins/transformers/
│   ├── .claude-plugin/plugin.json
│   ├── agents/        12 agent definitions with distinct personas
│   ├── commands/      12 slash commands
│   ├── skills/         5 knowledge skills injected into agents
│   ├── hooks/          Security handled by core-principles, not hooks
│   └── knowledge/      Shared rules: build patterns, test strategies,
│                       review checklist, core principles
└── README.md
```

---

## License

MIT

---

*"Till all are one." — Optimus Prime*
