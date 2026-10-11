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
- Checks the real WUK-15-to-Shared handoff save/reload, every MOVE's current location and persistence, Longma's real recruitment, LONGMA-02's read-only playback/completion/reload, and then verifies the final post-Shared-04 save is at Shared-05 with Black Wind North Path current, chapters 01–04 completed and timeline advanced. LONGMA-01 remains available while LONGMA-02 is recorded as played.

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
- Single-save production MainMenu / Journey smoke covers WUK-15 real END → Shared-01 → Shared-02 → Shared-03 battle/resume and Longma recruitment → actual LONGMA-02 playback and completion → Shared-04 end-to-end.
- Canonical Shared movement points are checked through state mutation and save/reload.
- Final save is inspected using a fresh NarrativeManager; LONGMA-01 remains available and LONGMA-02 is marked played.
- Runtime suite remains at 44 registered entries.

## Godot Runtime status
**PASS** — integrated implementation commit `b4aa8ef0515354d12705cedd5715bd5321415e30`. Godot Runtime run [38119684898](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684898) passed with `PASS res://combat/test_shared_opening_to_black_wind_smoke.gd` and `RUNTIME_SUITE_PASS tests=44`. Web Demo run [38119684880](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684880) build and deploy both passed. The intermediate test-only commit `85655409e38f84f851ec1c0568d1ab27f223bbce` failed due to an unindented nested `if`; `e83e07fd5d18660d92f9ea862f73444e3f1de161` fixed parsing but failed the stale assertion that LONGMA-02 still be available after being played. The final correction at `b4aa8ef` aligns the persisted assertions to available/played semantics.

## Known issues
- WUK-01..14 are seeded through canonical manager progression rather than replayed through UI; WUK-15's final EventSequence END → Shared-01 now runs via production MainMenu / Journey in this same smoke.
- Combat turns remain shortcut by invoking the production battle completion callback; this test covers transition / settlement / progression, not combat balance.

## Next step
Next, review the vertical slice's story pacing, interactive exploration and production character assets instead of adding framework-only work.

## Handoff point
Shared-01 to Shared-04 contiguous saved arc. Keep chronology, current map location, recruitment, and Memory availability in sync.
