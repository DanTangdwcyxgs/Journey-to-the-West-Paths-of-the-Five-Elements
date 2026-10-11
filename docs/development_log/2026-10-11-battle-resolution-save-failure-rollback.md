# 2026-10-11 · BattleResolutionService Save-Failure Rollback Regression

## Goal
Prove that the unified narrative battle resolution restores the pre-battle state when persistence fails after rewards and progression have already been applied in memory.

## Starting verification
- The existing `combat/test_battle_resolution_service.gd` covered invalid-source rejection before mutation, successful shared recruitment settlement, and stale duplicate settlement.
- It did not directly exercise the later rollback branch reached when `manager.save()` fails.
- Current stable baseline includes the full EventSequence catalog gate, validated on implementation commit `0e3998318ea771cee07a3343bc82986e04c3a1e8` by Runtime run [38105696943](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105696943).

## What changed
- Added a test-only `SaveFailingNarrativeManager` whose `save()` returns `false` and records whether the save boundary was reached.
- Reused a valid Shared-03 / Eagle Sorrow snapshot to pass preflight and allow BattleResolutionService to apply rewards and progression before the forced save failure.
- Asserted the service attempted to save, returned an empty result, and restored the exact serialized NarrativeState snapshot. Snapshot equality covers inventory, recruited companions, journey log, milestones and shared chapter state.
- Production battle-resolution code and runtime-suite registration remain unchanged; the existing test entry already runs in `tests/runtime_suite.gd`.

## Why
Atomicity requires rollback not only for invalid input, but also when a late commit step fails. This regression would catch partial rewards or recruitment being left in memory after a failed save.

## Systems affected
- BattleResolutionService transactional boundary
- NarrativeManager snapshot restoration
- Godot Runtime regression coverage

## Files
- `combat/test_battle_resolution_service.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-battle-resolution-save-failure-rollback.md`

## Tests
- Existing invalid-source / no-mutation regression remains.
- New forced-save-failure regression verifies failure reaches persistence and restores the pre-resolution snapshot.
- Existing valid settlement and duplicate-rejection assertions remain after the new case.

## Godot Runtime status
**PENDING** — confirm the exact implementation commit in GitHub Actions before claiming the nested test double compiles and rollback assertions pass.

## Known issues
- The regression tests the in-memory state rollback after save failure. It does not simulate physical disk corruption or operating-system process termination between write and flush.
- Shared recruitment battle scene transition remains a separate integration task.

## Next step
After exact-head Runtime and Web Demo results, continue the Shared recruitment battle's production SceneTree entry → BattleUI → resolution → EventSession resume smoke.

## Handoff point
BattleResolutionService / NarrativeManager transaction boundary. Rewards, recruitment and chapter progression must remain service-owned and all-or-nothing.
