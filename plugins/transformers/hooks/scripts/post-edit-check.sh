#!/bin/bash
# PostToolUse hook: lightweight guard after Edit/Write
# Checks for common issues that should never pass silently

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Check for hardcoded secrets patterns
if [ -f "$FILE_PATH" ]; then
  # Look for common secret patterns in the changed file
  SECRETS=$(grep -inE '(api[_-]?key|secret[_-]?key|password|token|credential)\s*[:=]\s*["\x27][^"\x27]{8,}' "$FILE_PATH" 2>/dev/null | head -3)

  if [ -n "$SECRETS" ]; then
    echo '{"decision": "block", "reason": "SECURITY: Possible hardcoded secret detected in '"$FILE_PATH"'. Review before proceeding."}' >&2
    exit 2
  fi
fi

# All clear
exit 0
