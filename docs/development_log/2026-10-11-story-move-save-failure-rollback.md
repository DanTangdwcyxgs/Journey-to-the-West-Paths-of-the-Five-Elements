# 2026-10-11 · Story MOVE Save-Failure Rollback

## Goal
Guarantee that a transient save failure during a narrative MOVE cannot leave the WorldMap at a location the save did not commit, and does not skip the movement node.

## Starting point
- Commit `0aa7d6bffb22c03d05f51d95a09ee3e57f1927d5` connected Shared-04's production MOVE node to `WorldActionService.apply_move()` and save-before-advance.
- Its SceneTree regression passed Runtime [38116737816](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737816) (40/40) and Web Demo [38116737826](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737826) build/deploy.
- Successful-path smoke alone did not assert the forced save-failure branch.

## What changed
- Added `combat/test_story_move_save_failure_rollback.gd`, which uses a NarrativeManager test double whose `save()` always returns false.
- The test enters the production Shared-04 sequence at departure dialogue, advances to its MOVE action and runs the actual Journey transition timer / commit path.
- Asserts one save attempt, exact NarrativeState rollback, restoration of FIVE_ELEMENTS_MOUNTAIN as current location, unchanged MOVE EventSession cursor, cleared transition lock, enabled retry button and visible failure feedback.
- The Runtime suite now expects 41 registered test entries.

## Why
Location changes are durable world facts, while the event graph owns chronology. A failed save must not allow the latter to advance past a movement fact that was not committed to the former.

## Systems affected
- Journey MOVE transaction boundary
- WorldActionService / NarrativeState
- EventSession cursor retry behavior
- Runtime regression suite

## Files
- `combat/test_story_move_save_failure_rollback.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-story-move-save-failure-rollback.md`
- `docs/development_log/2026-10-11-story-move-world-map.md`

## Tests
- Forced save failure after WorldActionService has mutated current/visited/discovered location.
- EventSession must remain at MOVE and UI must offer retry.

## Godot Runtime status
**PASS** — exact implementation commit `1b84b1abcf668b9d2d96412822fa00c7a43a9ecc`. Godot Runtime run [38116864150](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116864150) passed with `PASS res://combat/test_story_move_save_failure_rollback.gd` and `RUNTIME_SUITE_PASS tests=41`. Web Demo run [38116864144](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116864144) build and deploy passed.

## Known issues
- The test forces save() to fail in memory; it does not simulate operating-system process termination during a disk write.
- Free exploration still observes WorldMapManager's current timeline, milestone and connection gates.

## Next step
Next, the optional rumor/bounty branch from Black Wind North Path to Eagle Sorrow is covered by `2026-10-11-world-map-rumor-bounty-return.md`; after that passes, inspect how exploration returns to the canonical Shared chapter sequence.

## Handoff point
MOVE transaction rollback. NarrativeState and EventSession must agree: no durable location means no advanced story cursor.
