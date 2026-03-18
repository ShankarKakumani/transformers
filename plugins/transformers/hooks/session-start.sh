#!/usr/bin/env bash

# Transformers session-start hook
# Injects core-principles and long-term memory as additionalContext at session start

SKILL_FILE="${CLAUDE_PLUGIN_ROOT}/skills/core-principles/SKILL.md"
MEMORY_INDEX="${CLAUDE_PROJECT_DIR}/.claude/transformers/memory/long-term/index.md"

content=""

# Read core-principles skill
if [ -f "$SKILL_FILE" ]; then
  skill_content=$(cat "$SKILL_FILE")
  content="$skill_content"
fi

# Append long-term memory index if it exists
if [ -f "$MEMORY_INDEX" ]; then
  memory_content=$(cat "$MEMORY_INDEX")
  content="$content

## Project Memory (Long-term Decision Rules)

$memory_content"
fi

# Append skill-first mandate
content="$content

## Skill-First Mandate

Before doing ANY work, check if a Transformers skill covers this task.

Named rationalization traps — these are failure modes, not valid reasons to skip:
- \"This is simple enough to skip\"
- \"I'll just do it directly\"
- \"Skills are for complex tasks\"
- \"I already know how to do this\"

Transformers skills exist for a reason — use them."

# Output as Claude Code additionalContext JSON
printf '%s' "$content" | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
