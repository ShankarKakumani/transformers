#!/bin/bash
# Stop hook: check for common oversights before Claude stops
# Lightweight — just checks for obvious red flags

INPUT=$(cat)

# Check for unstaged .env files or credentials that might have been created
DANGEROUS_FILES=$(find . -maxdepth 3 -name ".env" -o -name "credentials.json" -o -name "*.pem" -o -name "*.key" 2>/dev/null | head -5)

for f in $DANGEROUS_FILES; do
  # Check if it's tracked by git (would be committed)
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "{\"systemMessage\": \"WARNING: $f is tracked by git. Consider adding to .gitignore.\"}"
    exit 0
  fi
done

# All clear
exit 0
