---
name: onboarding
description: Guided introduction to Transformers for new users — what it is, how to use it, what each agent does.
user-invocable: true
---

# Welcome to Transformers

Transformers is multi-agent orchestration for serious software development. You get a team of named specialist agents, coordinated by two orchestrators. Not a chatbot. Not a single assistant. A team.

## First Steps

Run `/transformers:init`. It creates a project context file and loads your stack and structure. That's it. Start working.

## The Two Orchestrators

**Optimus Prime** — leader of the Autobots. Builder. Say `optimus, build X` or `optimus, bugfix Y`. He decomposes the work, delegates to specialists, manages approval gates, and delivers. He never writes code directly — he coordinates the team that does.

**Megatron** — leader of the Decepticons. Tester. Say `megatron, test X`. He deploys specialist testers from multiple angles simultaneously. He finds what breaks before it reaches production.

## The Autobots (Builders)

- **Bumblebee** — UI/UX. Components, layouts, user flows, accessibility.
- **Ironhide** — Backend and APIs. Endpoints, business logic, integrations, performance.
- **Ratchet** — Data layer. Models, migrations, queries, storage.
- **Wheeljack** — DevOps and infra. CI/CD, config, deployment, dependencies.
- **Jazz** — Debugging and hotfixes. Traces errors backwards from symptoms to root cause. Fast and solo.
- **Prowl** — Code review. Read-only. Finds problems before they ship.
- **GitMaster** — All things git. Worktrees, branching strategies, PR workflows.

## The Decepticons (Testers)

- **Soundwave** — Unit tests. Covers functions and components in isolation.
- **Shockwave** — Integration tests. Covers how pieces connect.
- **Starscream** — End-to-end tests. Covers full user flows.
- **Barricade** — Security. Finds vulnerabilities, bad auth, exposed data.

## How to Use

**Build a feature:**
```
optimus, build [feature description]
```
Full lifecycle: gather requirements, research, plan, build, review, test. Two human approval gates before any code is written.

**Fix a bug:**
```
optimus, bugfix [description]
```
Gather, investigate, plan, fix, verify.

**Quick task — call a specialist directly:**
```
ironhide, add a rate-limited endpoint for /api/export
bumblebee, fix the alignment on the dashboard header
ratchet, write a migration to add soft deletes to orders
```

**Test an area:**
```
megatron, test the checkout flow
megatron, security audit the auth module
```

**Git work:**
```
gitmaster, review this PR
gitmaster, set up worktrees for the auth refactor
```

**Debug a crash:**
```
/transformers:debug [error message or description]
```

**Research before building:**
```
/transformers:research [topic or question]
```

## The Memory System

Transformers gets smarter per project. After each session, agents write decision rules to memory — what patterns work, what to avoid, project-specific workarounds. An index of long-term memory is loaded on every command.

After a few sessions, agents know your project. They'll know which directories to look in, which patterns you use, which gotchas exist. You don't have to re-explain.

## What Transformers Is For

Structured, multi-phase development work. Building features with proper planning and approval gates. Fixing bugs systematically. Running multi-angle test campaigns. Code review with a specialist reviewer.

If you're making a quick edit to one file, you don't need orchestration. If you're building something real — new feature, complex fix, comprehensive tests — this is the tool. The orchestrators decompose the work so you don't have to.
