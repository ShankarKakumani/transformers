---
name: extending-transformers
description: How to create effective Transformers skills — structure, progressive disclosure, bundled resources, testing.
user-invocable: false
---

# Writing Transformers Skills

A skill injects reusable knowledge into one or more agents. It is not an agent. It is not a command. It is a protocol — a set of rules that changes how an agent behaves when that skill is loaded.

## Skill File Structure

Every skill lives in its own directory under `plugins/transformers/skills/`. The directory must contain a `SKILL.md` file. Additional `.md` files in the same directory can be bundled and referenced from `SKILL.md`.

```
skills/
  my-skill/
    SKILL.md          ← required, the skill manifest
    reference.md      ← optional, bundled content
    examples.md       ← optional, more bundled content
```

**SKILL.md frontmatter schema:**

```yaml
---
name: my-skill                     # kebab-case, matches directory name
description: One sentence. What this skill teaches and when it applies.
user-invocable: true|false         # true = users can load it manually
---
```

Reference bundled files using the plugin root variable:

```markdown
@${CLAUDE_PLUGIN_ROOT}/skills/my-skill/reference.md
```

## What Belongs Where

**Skill** — reusable protocols that apply to specific contexts. Examples: how to write migration plans, how to use git worktrees, how to structure API endpoints. Injected into agents that need that knowledge.

**Agent** — a persona with tools, a model, and a job. Bumblebee does UI. Ironhide does backend. An agent is a specialist. A skill makes a specialist better at something specific.

**core-principles** — universal rules that apply to every agent in every context. Human-in-the-loop, honesty, scope discipline, loop detection. If a rule should always be true for all agents, it belongs in core-principles, not a skill.

When in doubt: if the rule is situational (only relevant when doing X), it's a skill. If it's always true, it's core-principles. If it requires a tool and a persona, it's an agent.

## What Makes a Good Skill

**Clear trigger conditions.** The skill should say when it applies. "Use this when building REST endpoints" is clearer than "use this for backend work."

**Progressive disclosure.** Lead with the overview. Put details further down or in bundled files. Agents reading a 500-line skill will skim or miss things. Keep the main SKILL.md tight — 100-200 lines is a good target.

**Concrete over abstract.** "Use `RETURNING id` in INSERT statements" beats "write efficient SQL." Rules that agents can follow mechanically are better than principles they have to interpret.

**Bundled resources for depth.** If the skill needs examples, checklists, or reference tables, put them in separate files and reference them. The main SKILL.md should read like a briefing, not a textbook.

## Naming

Use kebab-case. Prefer verb-noun format:

- `using-git-worktrees`
- `writing-plans`
- `writing-migrations`
- `reviewing-prs`

Noun-only names are acceptable when the skill is a reference rather than a protocol: `api-conventions`, `test-patterns`.

## Wiring a Skill to an Agent

In the agent's `.md` frontmatter, add a `skills` list:

```yaml
---
name: ironhide
model: claude-sonnet-4-5
skills:
  - core-principles
  - writing-migrations
  - api-conventions
---
```

Skills are injected in order. Later skills can override or extend earlier ones. Put core-principles first — always.

## Testing a Skill

Spawn a subagent with the skill loaded and give it a task that exercises the skill. Check if the behavior is different from an agent without the skill.

Example test prompt: "You have the `writing-migrations` skill loaded. Write a migration that adds an index to the `users` table." Then compare output to the same prompt without the skill.

If the skill works, the agent's output should visibly reflect the rules in the skill. If it doesn't change behavior, the skill is too vague.

## Anti-Patterns

**Too long.** If SKILL.md exceeds 300 lines, break it up. Move examples to bundled files. Nobody reads a wall of text under pressure.

**Too vague.** "Write clean code" is not a skill rule. "Extract functions longer than 20 lines" is. Make rules actionable.

**Duplicating core-principles.** Don't re-state "wait for human approval before destructive actions." It's already in core-principles. Duplication creates drift — someone will update one but not the other.

**Replacing agents.** A skill that says "you are now a database expert" is wrong. Skills augment specialists. They don't replace them. Ratchet is the database expert. A skill teaches Ratchet how to handle a specific migration pattern.

## The Transformers Identity

Transformers is multi-agent orchestration with named specialists. Skills reinforce this by making specialists better at specific tasks — not by turning generalists into specialists.

When writing a skill, ask: which agent does this skill make more effective? Wire it to that agent. If the answer is "all agents," it probably belongs in core-principles.
