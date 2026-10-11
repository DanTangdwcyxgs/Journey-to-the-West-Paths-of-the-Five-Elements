# 2026-10-11 · Single-Save Shared Opening → Black Wind North Path Arc

## Goal
Validate one contiguous saved production UI flow from the final Wukong Origin chapter through Shared-01..04, including Longma recruitment and a read-only Longma Memory playback.

## Starting point
- WUK-15 final Origin END → Shared-01 was fixed and passed on commit `deba063d42c46156b37b313f8b59863d2e558949` (Runtime 38/38 + Web Demo pass); the handoff save-failure rollback passed on follow-up `efb1e7c1cfdfe6dd84fd5618bd0405c72f2f377f` (Runtime 39/39 + Web Demo pass).
- Shared chapter story MOVE markers now cover Five Elements Mountain, Eagle Sorrow, Black Wind North Path, Gaojiazhuang and Flowing Sands. Commit `5e0e11ca890e1469e8b88fd2121c55c10e6f32d4` passed Runtime [38117827110](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117827110) (42/42) and Web Demo [38117827051](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117827051) build/deploy.
- Existing tests independently covered Shared-01, Shared-03 battle/resume and Shared-04 MOVE, but did not play these steps consecutively on the same production save.

## What changed
- Added `combat/test_shared_opening_to_black_wind_smoke.gd` to the Runtime suite.
- Seeds canonical WUK-01..14 completion through the chapter manager while leaving WUK-15 current, then enters production MainMenu Continue → Journey and executes the real WUK-15 EventSequence END / Origin-to-Shared handoff.
- Uses real Journey choice buttons and EventSession controls to complete Shared-01, Shared-02, Shared-03, and Shared-04 in sequence. After real Longma recruitment, it selects LONGMA-02 in the Journey sidebar, plays both canonical text dialogue entries without running historical combat, completes the memory and reloads the save before continuing Shared-04.
- Shared-03 switches into the production BattleUI, resolves the real Longma recruitment settlement, returns through the production button and completes the after-battle EventSession.
- Checks every MOVE's current location and its save/reload, then verifies the final post-Shared-04 save is at Shared-05 with Black Wind North Path as current location, chapters 01–04 completed, timeline advanced, Longma recruited and Longma memories unlocked.

## Why
The player experiences these chapters as one connected journey; testing each chapter from an independent fixture can miss persistence boundaries, stale current locations or progression that only appears correct after reinitializing a manager.

## Systems affected
- Shared chapter chronology and EventSequence sessions
- WorldMap current location and save transaction
- Shared-03 battle handoff / resume
- Recruitment and Memory unlocks

## Files
- `combat/test_shared_opening_to_black_wind_smoke.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-single-save-shared-opening-black-wind.md`

## Tests
- Single-save production MainMenu / Journey smoke covers Shared-01 / Shared-02 / Shared-03 battle + resume / Shared-04 end-to-end.
- All canonical Shared movement points are checked through the state mutation and a reload.
- Final progression save is inspected independently using a fresh NarrativeManager.
- Expected Runtime suite entries: 43.

## Godot Runtime status
**PASS** — exact implementation commit `7b1b08a83448419f9cbd867cd15b7dd1f5905a06`. Godot Runtime run [38118079231](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079231) passed with `PASS res://combat/test_shared_opening_to_black_wind_smoke.gd` and `RUNTIME_SUITE_PASS tests=43`. Web Demo run [38118079238](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079238) build and deploy both passed.

## Known issues
- WUK-01..14 are seeded through canonical manager progression rather than replayed through UI; WUK-15's final EventSequence END → Shared-01 now runs via production MainMenu / Journey in this same smoke.
- Combat turns remain shortcut by invoking the production battle completion callback; this test covers transition / settlement / progression, not combat balance.

## Next step
After this integrated smoke passes, review the vertical slice's story pacing, interactive exploration and production character assets instead of adding framework-only work.

## Handoff point
Shared-01 to Shared-04 contiguous saved arc. Keep chronology, current map location, recruitment, and Memory availability in sync.
