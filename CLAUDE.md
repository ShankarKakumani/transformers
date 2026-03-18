# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Transformers is a Claude Code plugin providing multi-agent orchestration for software development. 13 specialized agents (7 Autobots for building, 5 Decepticons for testing, 1 utility) are coordinated by two orchestrators (Optimus for builds, Megatron for tests).

**Current version:** defined in `.claude-plugin/marketplace.json`

## Repository Structure

```
plugins/transformers/
├── agents/          # Agent definitions (13 .md files with frontmatter)
├── commands/        # Slash command definitions (13 .md files)
├── knowledge/       # Shared rules injected via skills (core-principles, build-patterns, test-strategies, code-review-checklist)
├── skills/          # Skill bundles (SKILL.md + content files per skill)
└── hooks/hooks.json # Plugin hooks (intentionally empty)

.claude-plugin/marketplace.json  # Plugin marketplace registration
plugins/transformers/.claude-plugin/plugin.json  # Plugin definition
```

## Architecture

### Agent System

**Orchestrators** (Opus model, delegation only — never code directly):
- **Optimus** — Build orchestrator. Decomposes features into parallel/sequential chunks, delegates to builder agents.
- **Megatron** — Test orchestrator. Deploys tester agents from multiple attack angles.

**Builders (Autobots)** (Sonnet model):
- Bumblebee (UI/UX), Ironhide (backend/APIs), Ratchet (data layer), Wheeljack (DevOps), Jazz (debugging), Prowl (code review — read-only)

**Testers (Decepticons)** (Haiku for unit/integration, Sonnet for E2E/security):
- Soundwave (unit), Shockwave (integration), Starscream (E2E), Barricade (security)

**Utility**: Scribe (Haiku) — activity logging and report generation

### Command Types

**Lifecycle commands** (multi-phase with 2 human approval gates):
- `feature` — gather → research → plan → build → review → test → summary
- `bugfix` — gather → investigate → plan → fix → verify → summary

**Standalone commands**: brainstorm, research, explain, refactor, debug, test, pr-generator, commit-generator, commit-and-push, init, report

### Knowledge System

Skills in `skills/` inject shared knowledge into agents. Each skill has a `SKILL.md` manifest and content files. Knowledge files in `knowledge/` define cross-cutting rules (core principles, build patterns, test strategies, review checklists).

### Artifact Tracking

Lifecycle commands create artifacts in `.claude/transformers/.temp/features/` or `.claude/transformers/.temp/bugfix/`:
- Phase files: `00-gather.md`, `01-research.md`, `02-plan.md`, `03-build-log.md`, `04-review.md`
- `status.md` — checkpointing for context recovery after `/compact`
- `05-tokens.md` — sub-agent token usage tracking

## Key Conventions

### Agent Definition Format

Each agent `.md` file uses YAML frontmatter with fields: `name`, `model`, `description`, `tools`, `allowed_tools`. The body contains the agent's system prompt including persona, responsibilities, and behavioral rules.

### Command Definition Format

Each command `.md` file uses YAML frontmatter with: `name`, `description`, `allowed-tools`. The body defines the command's execution flow, phases, and gate logic.

### Sub-agent Context Protection

Critical pattern: orchestrators must instruct sub-agents to write detailed output to artifact files and return only 1-3 line summaries. This prevents context window exhaustion.

### Memory System

Agents learn from every task. Two tiers:
- **Temporary** (`memory/temp.md`) — per-conversation, shared across all active work. Any agent can read/write.
- **Long-term** (`memory/long-term/`) — per-project, cross-conversation. Topic-based files with an `index.md` loaded by auto-init on every command.

Sub-agents propose learnings via `[MEMORY]` or `[LONG-TERM]` tags. Orchestrators decide what graduates from temp to long-term. Standalone commands write directly via Scribe.

Knowledge file: `knowledge/memory-system.md`. Skill: `skills/memory/`.

### Loop Detection

All agents must detect and break loops (repeated searches, re-reading files, retrying failed approaches). On detection: state what was tried, pivot approach, or escalate to user.

## Editing Guidelines

- Agent/command files are Markdown with YAML frontmatter — preserve the frontmatter schema
- When modifying agent behavior, check if the rule belongs in the agent file or in a shared knowledge file
- Orchestrators (Optimus/Megatron) should never have tools that write code directly
- Prowl is read-only — never give it write/edit tools
- Model assignments matter: Opus for orchestrators, Sonnet for complex builders/testers, Haiku for high-volume/simple agents
- Hooks file is intentionally empty — security rules live in core-principles skill instead

## Version Bumping

Update version in `.claude-plugin/marketplace.json` when making changes. Follow semver: major for breaking changes, minor for new commands/agents, patch for fixes.
