# Transformers

```
──────────▄▄▄▄▄▄▄▄▄──────────
───────▄█████████████▄───────
▐███▌─█████████████████─▐███▌
─████▄─▀███▄─────▄███▀─▄████─
─▐█████▄─▀███▄─▄███▀─▄█████▌─
──██▄▀███▄─▀█████▀─▄███▀▄██──
──▐█▀█▄▀███─▄─▀─▄─███▀▄█▀█▌──
───██▄▀█▄██─██▄██─██▄█▀▄██───
────▀██▄▀██─█████─██▀▄██▀────
───▄──▀████─█████─████▀──▄───
───██────────███────────██───
───██▄────▄█─███─█▄────▄██───
───████─▄███─███─███▄─████───
───████─████─███─████─████───
───████─████─███─████─████───
───████─████▄▄▄▄▄████─████───
───▀███─█████████████─███▀───
─────▀█─███─▄▄▄▄▄─███─█▀─────
────────▀█▌▐█████▌▐█▀────────
───────────███████───────────

 ╔══════════════════════════════════════╗
 ║   AUTOBOTS BUILD. DECEPTICONS TEST. ║
 ╚══════════════════════════════════════╝
```

AI-powered build and test orchestration plugin for [Claude Code](https://claude.ai/code). Autobots build. Decepticons test.

## What is this?

A Claude Code plugin that gives you a team of specialized AI agents, each with a distinct personality and thinking style. One orchestrator decomposes your task and delegates to the right agents. Another orchestrator attacks your code from every angle.

## The Roster

### Autobots — Build Team

| Agent | Personality | Thinks about... |
|-------|------------|----------------|
| **Optimus** | Calm, strategic leader | Decomposition, delegation, big picture |
| **Bumblebee** | Enthusiastic, user-empathetic | UX, user perspective, how it feels |
| **Ironhide** | Blunt, no-nonsense veteran | Core problem, shortest path, load |
| **Ratchet** | Methodical, paranoid about data | Integrity, migrations, rollback |
| **Wheeljack** | Inventive, automation-obsessed | Automation, debuggability, 3am failures |
| **Jazz** | Cool, creative under pressure | Symptoms, traces, creative fixes |
| **Prowl** | Cold, analytical enforcer | Patterns, consistency, the rulebook |

### Decepticons — Test Team

| Agent | Personality | Attacks... |
|-------|------------|-----------|
| **Megatron** | Ruthless, strategic commander | Weakest links, systematically |
| **Soundwave** | Silent, misses nothing | Every edge case, boundary, null |
| **Shockwave** | Pure logic, cold | Connections, contracts, failures |
| **Starscream** | Ambitious, wants the big kill | Full user flows, showstoppers |
| **Barricade** | Suspicious of everything | Injection, auth bypass, data leaks |

## Installation

```bash
# Add as marketplace (one-time)
/plugin marketplace add ShankarKakumani/transformers

# Install the plugin
/plugin install transformers@transformers
```

Or test locally:
```bash
claude --plugin-dir ~/path/to/transformers
```

## Usage

### Full pipeline (build + review + test)
```
/transformers:transformers add a search bar to the dashboard
```

### Build only (Autobots + Prowl review)
```
/transformers:autobots implement caching for the API layer
```

### Test only (Decepticons attack)
```
/transformers:decepticons test the authentication module
```

## How it works

```
/transformers
  Phase 1: Optimus decomposes → spawns Autobots in parallel
  Phase 2: Prowl reviews all changes
  Phase 3: Megatron assesses → spawns Decepticons in parallel
  Phase 4: Leaders store learnings to project memory
```

### Model allocation (token-efficient)

| Agent | Model | Why |
|-------|-------|-----|
| Optimus, Megatron | Opus | Strategic orchestration needs deep reasoning |
| Bumblebee, Ironhide, Ratchet, Wheeljack, Jazz, Prowl | Sonnet | Capable execution, cost-effective |
| Soundwave, Shockwave | Haiku | Fast, repetitive test work, cheap |
| Starscream, Barricade | Sonnet | E2E/security need more reasoning |

### Key features

- **Personality-driven delegation** — same tools, different thinking styles
- **Parallel execution** — independent tasks run simultaneously
- **Human in the loop** — confirms before architectural decisions, scope changes, irreversible actions
- **Impact analysis** — checks blast radius before every change
- **Web research** — searches GitHub issues, docs, changelogs when stuck
- **Security awareness** — flags hardcoded secrets, dangerous packages, supply chain risks
- **Context management** — checkpoints progress, provides continuation prompts
- **Project memory** — leaders learn patterns and gotchas across sessions
- **Test reality check** — adapts when projects don't have test infrastructure
- **Honesty** — says "I don't know" instead of faking it

## Core Principles

Every agent follows these rules:

1. **Human is the architect** — agents build, human decides
2. **Never fake it** — no stubs, no placeholders, no guessing presented as fact
3. **Impact before action** — check who else is affected before changing code
4. **Research before guessing** — search the web, check GitHub issues, verify
5. **Continuous improvement** — learn from failures, recommend better approaches
6. **Security first** — no secrets in code, no dangerous packages, no supply chain risks
7. **Context discipline** — protect the context window, checkpoint early, clean up memory

## Plugin Structure

```
transformers/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/transformers/
│   ├── .claude-plugin/plugin.json
│   ├── agents/          (12 agents with personas)
│   ├── commands/        (3 slash commands: /transformers, /autobots, /decepticons)
│   ├── skills/          (4 knowledge skills injected into agents)
│   ├── hooks/           (auto-review on edits, completeness check)
│   └── knowledge/       (build patterns, test strategies, review checklist, core principles)
└── README.md
```

## License

MIT
