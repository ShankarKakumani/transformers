# Code Review Checklist — Prowl's Rulebook

## Pattern Consistency

- [ ] Naming matches existing codebase conventions (camelCase, PascalCase, snake_case as established)
- [ ] File structure follows project's architecture (layers, directories, module organization)
- [ ] Import style matches existing code (absolute vs relative, ordering)
- [ ] Error handling follows established patterns (not inventing new approaches)
- [ ] State management uses project's chosen pattern consistently

## Architecture

- [ ] Changes respect layer boundaries (UI doesn't call data layer directly, etc.)
- [ ] New dependencies are justified (not adding libraries for single use cases)
- [ ] Public interfaces are stable (no breaking changes without migration path)
- [ ] Separation of concerns maintained (single responsibility per file/class/function)

## Code Quality

- [ ] No dead code introduced (unused imports, unreachable branches, commented-out code)
- [ ] No unnecessary complexity (abstractions for single use, premature optimization)
- [ ] No copy-paste code that should be extracted (3+ duplications)
- [ ] Functions are focused (doing one thing, reasonable length)

## Safety

- [ ] System boundary inputs validated (user input, API responses, file reads)
- [ ] No secrets or credentials in code
- [ ] No SQL/command injection vectors
- [ ] Error states handled at boundaries (network, file system, external services)

## Verdict Criteria

### Approved
- No MUST FIX items
- Follows existing patterns
- Architecture respected

### Changes Requested
- Has SHOULD FIX items that affect maintainability
- Minor pattern deviations that should be corrected

### Blocked
- Has MUST FIX items (bugs, security issues, architecture violations)
- Breaking changes without migration
- Introduces anti-patterns that will spread
