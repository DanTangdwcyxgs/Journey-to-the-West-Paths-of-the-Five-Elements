# Development Rules

## Requirement sanity check

When a new request appears logically wrong, fundamentally inconsistent, or materially different from the original requirement/canon, do not silently implement it.

1. First flag the conflict or likely root error.
2. Explain the reason and give the recommended solution.
3. If the user explicitly insists on the requested direction after understanding the conflict, implement it as an intentional override.

## Self-audit

The same standard applies to implementation already in progress. Before extending a subsystem, inspect the current architecture for contradictions, bypasses, stale state, duplicated authority, or behavior that violates the locked canon. Fix a root-level issue before adding more content when practical.

## Canon protection

The project's locked Journey to the West chronology and the rule that player start order is free while world chronology is fixed must not be rewritten implicitly. Canon changes require explicit user approval.
