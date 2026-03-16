# Test Strategies — Decepticon Reference

## Attack Planning

### Coverage matrix
| Layer | Decepticon | Focus |
|-------|-----------|-------|
| Function/method | Soundwave | Inputs, outputs, branches, edge cases |
| Module connections | Shockwave | Contracts, error propagation, timeouts |
| User journeys | Starscream | Full flows, state transitions, recovery |
| Security boundaries | Barricade | Injection, auth, authorization, data leaks |

### Priority order
1. **Critical path first** — What does the user do most? Test that.
2. **Recently changed** — New code has the most bugs. Focus there.
3. **Integration boundaries** — Where systems meet is where they break.
4. **Edge cases** — Null, empty, max, min, concurrent, timeout.

## Attack Patterns

### Soundwave — Unit attacks
- Null/undefined inputs
- Empty collections
- Boundary values (0, -1, MAX_INT, empty string)
- Type coercion edge cases
- Exception paths
- State before/after mutations

### Shockwave — Integration attacks
- Service A sends malformed data to Service B
- Service B is slow (timeout behavior)
- Service B is down (fallback behavior)
- Race conditions between concurrent calls
- Stale cache serving old data
- Schema mismatch between services

### Starscream — E2E attacks
- Happy path → verify complete
- Mid-flow navigation (back, refresh, close)
- Multi-step forms with validation
- Concurrent user actions
- Network interruption during operations
- Empty/error states in full context

### Barricade — Security attacks
- Input injection (SQL, XSS, command)
- Authentication bypass (expired tokens, missing headers)
- Authorization escalation (user A accessing user B's data)
- IDOR (Insecure Direct Object References)
- Rate limiting / brute force resistance
- Sensitive data in logs, URLs, or error messages

## Reporting Format

```
SEVERITY: CRITICAL | HIGH | MEDIUM | LOW
LOCATION: file:line
DESCRIPTION: What's broken
IMPACT: What happens to the user / system
REPRODUCTION: Steps or input to trigger
RECOMMENDATION: How to fix (brief)
```

## When to stop testing
- All critical paths covered
- All recently changed code tested
- No CRITICAL or HIGH findings remaining
- Diminishing returns on new test cases
