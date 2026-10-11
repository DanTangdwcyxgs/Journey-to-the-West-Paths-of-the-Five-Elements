# 2026-10-11 · Origin Final Handoff Save-Failure Rollback

## Goal
Keep the in-memory party roster/formation consistent with NarrativeState when the final Origin → Shared handoff reaches the save boundary but persistence fails.

## Starting point
- Commit `deba063d42c46156b37b313f8b59863d2e558949` fixed the production WUK-15 END → Shared-01 handoff and passed Runtime [38116199981](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116199981) (38/38) and Web Demo [38116199980](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116199980).
- Review of the rollback path found that NarrativeState was restored after save failure but PartyManager was not reinitialized from the restored save state.

## What changed
- Reinitialize PartyManager from the restored NarrativeState in both final-handoff rejection and save-failure rollback branches.
- Added `combat/test_origin_final_shared_handoff_rollback.gd`, using a test NarrativeManager whose `save()` always fails.
- The regression advances the canonical WUK-15 EventSequence to END, invokes the production finalization method and verifies exact serialized-state restoration, unchanged WUK-15 cursor, no half-committed Shared chapter, restored PartyManager roster/formation, visible failure feedback, and an END session that remains open for retry.
- Registered the test in the Runtime suite; expected entry count rises to 39.

## Why
Rollback must restore both authoritative narrative data and presentation-side projections derived from it. A split state can let the player see a recruited party that the save does not contain after a failed handoff.

## Systems affected
- OriginSequenceJourneyScreen save transaction
- NarrativeState rollback
- PartyManager roster/formation projection
- Godot Runtime regression suite

## Files
- `ui/origin_sequence_journey.gd`
- `combat/test_origin_final_shared_handoff_rollback.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-origin-final-shared-handoff.md`
- `docs/development_log/2026-10-11-origin-final-handoff-rollback.md`

## Tests
- Initial commit `bfa267ba1be413918189df9e4f94e7ff8886143f` failed Runtime because the scripted rollback insertion had inconsistent GDScript indentation at the handoff-rejected branch. That parse failure cascaded into tests that load `OriginSequenceJourneyScreen`; it was not a behavioral failure.
- Follow-up commit fixes the indentation and explicitly restores PartyManager for the save-failure branch as well as the handoff-rejected branch.
- New forced-save-failure regression drives the production WUK-15 session to END.
- Asserts serialized NarrativeState equals its pre-END snapshot and PartyManager matches its pre-END roster/formation.
- Confirms save was attempted exactly once, the session remains at END, and retry remains possible.
- Runtime suite expected registered entries: 39.

## Godot Runtime status
**PENDING** — only record green after Runtime and Web Demo complete on the exact implementation SHA.

## Known issues
- The test validates the late save failure in memory; it does not simulate OS process termination during a physical file write.
- A separate end-to-end new-game → full Origin route SceneTree smoke remains future coverage; current tests split the route progression, WUK-02 battle UI, and final WUK-15 handoff.

## Next step
After validation, continue the Wukong-to-Longma slice by integrating story movement / map locations with actual exploration UI and testing canonical Shared-04 travel into Black Wind North Path.

## Handoff point
Final Origin transaction rollback. NarrativeState remains authoritative; PartyManager must be rebuilt from it on every rollback path.
