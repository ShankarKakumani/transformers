---
type: long-term
topic: version-sync
source: init (2026-03-18)
---

# Version Sync

- Two version files must always match: `.claude-plugin/marketplace.json` and `plugins/transformers/.claude-plugin/plugin.json`
- CI syncs them automatically on tag push via `jq`. For manual version bumps (pre-tag), update both files.
- Current version at init time: 3.4.1
