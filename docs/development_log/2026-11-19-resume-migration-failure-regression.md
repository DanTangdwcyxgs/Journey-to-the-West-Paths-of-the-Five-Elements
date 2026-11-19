# 2026-11-19 — Active Handoff Preserved When Resume Migration Fails

## Goal

Add deterministic failure-injection coverage for the remaining P0 data-safety invariant: if an active EventSession handoff cannot be migrated to `RESUME_PATH`, the active handoff must remain the only safe copy.

## Test design

- Added `combat/test_bounty_encounter_state_resume_migration_failure.gd` and registered it in `tests/runtime_suite.gd`.
- The test backs up the existing `active_bounty.json` and `pending_event_resume.json` files.
- It writes an active narrative battle handoff containing a serialized `event_resume` snapshot.
- It creates a directory at `RESUME_PATH`, making `FileAccess.open(RESUME_PATH, FileAccess.WRITE)` deterministically fail without relying on permissions, timing, or disk-full behavior.
- It calls the production `BountyEncounterState.clear()` method and verifies:
  - the active handoff still exists;
  - the active handoff bytes are exactly unchanged;
  - the blocking directory is still present (the production code did not delete or replace it);
  - no partial pending-resume file was created.
- The test removes its temporary directory and restores both previous user files before returning.

## Production code status

No production code change was necessary. `BountyEncounterState.clear()` already preserves the active record if it cannot open or persist the pending resume file. This test closes the previously missing deterministic regression.

## Validation

- Exact code/test SHA: `f3dca5a98ee72e15b2ca67cfb9a1157b272282c9`.
- Godot Runtime run [44446160315](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44446160315): **PASS**.
- Job log explicitly contains `PASS res://combat/test_bounty_encounter_state_resume_migration_failure.gd` and `RUNTIME_SUITE_PASS tests=58`.
- The pre-existing narrative battle defeat/retry roundtrip remains covered by `combat/test_origin_battle_defeat_retry_roundtrip.gd`; its exact-head run [44441787645](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44441787645) passed Runtime 57/57 before this new test was registered.

## State

- The two P0 data-safety items from the 2026-11-19 player-facing vertical-slice audit are now checked.
- PR #34 remains Draft/open/unmerged. No merge, deployment, or Web Demo export was performed.
- The 2026-11-19 Wukong image-generation work is separate on the art branch; this test does not modify images, catalog entries, or the runtime art pipeline.

## Next

Proceed with the P1 first-battle tutorial and a five-origin first-session acceptance matrix. Keep the chronology and optional-content boundaries unchanged.
