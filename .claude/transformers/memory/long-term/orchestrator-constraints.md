---
type: long-term
topic: orchestrator-constraints
source: init (2026-03-18)
---

# Orchestrator Constraints

- Orchestrators (Optimus, Megatron) must NEVER have Write, Edit, or Bash tools — they are delegation-only by design.
- Prowl must NEVER have Write or Edit tools — it is read-only by design.
- Adding code tools to orchestrators or write tools to Prowl breaks the architecture.
- auto-init skill is the system middleware — loaded by all orchestrators on every command. Changes here affect all workflows.
