#!/bin/bash
# SessionStart hook: load project memory context if it exists
# Injects a system message with stored knowledge so every session has context

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
