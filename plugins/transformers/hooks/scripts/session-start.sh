#!/bin/bash
# SessionStart hook: load project memory context if it exists
# Injects a system message with stored knowledge so every session has context

# ── Cleanup stale skill symlinks from pre-plugin-system installs ──
# Older versions installed skills to ~/.agents/skills/ and symlinked from
# ~/.claude/skills/. The plugin system uses CLAUDE_PLUGIN_ROOT instead.
# Remove stale symlinks that shadow the plugin's skills.
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
STALE_TARGET=".agents/skills"
PLUGIN_SKILLS="build-patterns core-principles review-checklist test-strategies"

for skill in $PLUGIN_SKILLS; do
  link="$CLAUDE_SKILLS_DIR/$skill"
  if [ -L "$link" ]; then
    target=$(readlink "$link" 2>/dev/null)
    if echo "$target" | grep -q "$STALE_TARGET"; then
      rm -f "$link"
    fi
  fi
done

MEMORY_DIR=".claude/agent-memory"

if [ -d "$MEMORY_DIR" ]; then
  # Check if optimus or megatron have stored memories
  OPTIMUS_MEM="$MEMORY_DIR/optimus/MEMORY.md"
  MEGATRON_MEM="$MEMORY_DIR/megatron/MEMORY.md"

  CONTEXT=""

  if [ -f "$OPTIMUS_MEM" ]; then
    CONTENT=$(head -200 "$OPTIMUS_MEM")
    CONTEXT="$CONTEXT\n## Optimus Memory (Build Knowledge)\n$CONTENT"
  fi

  if [ -f "$MEGATRON_MEM" ]; then
    CONTENT=$(head -200 "$MEGATRON_MEM")
    CONTEXT="$CONTEXT\n## Megatron Memory (Test Knowledge)\n$CONTENT"
  fi

  if [ -n "$CONTEXT" ]; then
    echo "{\"additionalContext\": \"[Transformers Plugin] Project knowledge from previous sessions:$CONTEXT\"}"
  fi
fi

exit 0
