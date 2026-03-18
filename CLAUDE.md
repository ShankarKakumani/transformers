# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Transformers is a Claude Code plugin providing multi-agent orchestration. It ships 14 specialized agents (Autobots for building, Decepticons for testing) coordinated by two orchestrators. All source files are Markdown with YAML frontmatter — no compiled code.

**Current version:** defined in `.claude-plugin/marketplace.json` (both files must stay in sync — see Version Bumping below).

## Repository Structure

```
plugins/transformers/
├── agents/          # Agent definitions (14 .md files with frontmatter)
├── commands/        # Slash command definitions (13 .md files)
├── knowledge/       # Shared rules injected via skills (core-principles, build-patterns, test-strategies, code-review-checklist, memory-system, git-*)
├── skills/          # Skill bundles (SKILL.md + content files per skill)
└── hooks/           # hooks.json with SessionStart hook

.claude-plugin/marketplace.json                  # Marketplace registration + version
plugins/transformers/.claude-plugin/plugin.json  # Plugin definition + version
.github/workflows/bump-version.yml               # Release automation
```

## Local Development

```bash
# Run Claude Code with the plugin loaded locally
claude --plugin-dir ~/path/to/transformers/plugins/transformers
```

There are no build steps, linters, or test runners — this is a pure Markdown/config plugin.

## Architecture

### Agent System

**Orchestrators** (`model: opus`, `Agent` tool only — no `Write`/`Edit`/`Bash`):
- **Optimus** — build orchestrator. Decomposes features into parallel/sequential chunks.
- **Megatron** — test orchestrator. Deploys testers from multiple attack angles.

**Builders (Autobots)** (`model: sonnet`, full file access, `permissionMode: acceptEdits`):
Bumblebee (UI/UX), Ironhide (backend/APIs), Ratchet (data layer), Wheeljack (DevOps), Jazz (debugging), GitMaster (git ops)

**Testers (Decepticons)** (read-only — no `Write`/`Edit`):
Soundwave/Shockwave (`model: haiku`), Starscream/Barricade (`model: sonnet`)

**Prowl** — read-only code reviewer. Never give it `Write`/`Edit` tools.

**Scribe** (`model: haiku`) — activity logging and report generation only.

### Agent Definition Format

YAML frontmatter fields: `name`, `description`, `model`, `tools` (list), `permissionMode` (optional), `maxTurns`, `background` (optional), `memory` (optional, `project` for orchestrators), `skills` (list).

### Command Types

**Lifecycle commands** (`feature`, `bugfix`) — 5 phases, 2 human approval gates, artifact tracking in `.claude/transformers/.temp/`. Sub-agents write detail to artifact files and return only 1-3 line summaries to protect orchestrator context.

**Standalone commands** — single-purpose, no approval gates: `brainstorm`, `research`, `explain`, `refactor`, `debug`, `test`, `pr-generator`, `commit-generator`, `commit-and-push`, `init`, `report`.

### Skill Bundle Format

Each skill: `skills/{name}/SKILL.md` + optional content files. SKILL.md frontmatter: `name`, `description`, `user-invocable: true|false`. Content referenced via `@${CLAUDE_PLUGIN_ROOT}/skills/{name}/file.md`.

Two patterns:
- **Reference delegate** — SKILL.md imports from `knowledge/` files (e.g., `core-principles`)
- **Self-contained** — full content inline (e.g., `memory`, `auto-init`, `verification`)

### Knowledge vs Skills

`knowledge/` files contain the actual rule content. `skills/` inject that content into agents. When a rule should apply to multiple agents, put it in `knowledge/` and reference it from a skill — don't duplicate it in agent files.

### `auto-init` — System Middleware

Loaded by Optimus and Megatron on every command. Handles: project context staleness check, memory hydration, artifact TTL pruning (2-day TTL on `.temp/` subdirs), in-progress work detection, activity logging. Changes here affect every workflow.

## Version Bumping

Two files must always be in sync:
- `.claude-plugin/marketplace.json` → `plugins[0].version`
- `plugins/transformers/.claude-plugin/plugin.json` → `version`

**Release flow:** push a tag → CI auto-updates both files and commits `chore: bump version to X.Y.Z` back to `main` → `git pull` after CI completes or your local will be behind.

```bash
git tag -a vX.Y.Z -m "release description"
git push origin main
git push origin vX.Y.Z
# Wait for CI, then:
git pull
```

For manual pre-tag bumps, update both files. Follow semver: major for breaking changes, minor for new commands/agents, patch for fixes.

## Editing Guidelines

- Preserve the YAML frontmatter schema when editing agent/command files
- When adding a behavioral rule, decide: does it belong in the agent file, or in a shared `knowledge/` file referenced by a skill?
- Orchestrators must never have `Write`, `Edit`, or `Bash` tools — delegation only
- Prowl must never have `Write` or `Edit` tools — read-only by design
- Model assignments matter: `opus` for orchestrators, `sonnet` for complex builders/testers, `haiku` for high-volume/simple agents
- The `hooks.json` file is not empty — it has a `SessionStart` hook; the CLAUDE.md inside `plugins/transformers/` is stale on this point
- Keep `knowledge/` files as the source of truth for shared rules — skills point to them, agents don't duplicate them
