# 2026-10-11 · Optional Bounty Return → Shared-05 Mainline

## Goal
Verify an optional bounty branch returns to the canonical story on the same save: after the player finishes an exploration fight, returns to Journey, and continues Shared-05, the mainline resumes at Gaojiazhuang without replaying completed Shared-04 or advancing chronology incorrectly.

## Starting point
- Current production Shared arc smoke passed on commit `7b1b08a83448419f9cbd867cd15b7dd1f5905a06`: Runtime [38118079231](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079231) passed 43/43 and Web Demo [38118079238](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38118079238) build/deploy passed.
- The existing optional-bounty scene smoke verified WorldMap → rumor → Yellow Fang bounty → BattleUI → WorldMap, while preserving current Shared chapter/timeline/completed chapters/roster. It did not click the production “返回行程” button or continue a Shared sequence.
- The previous fixture used Shared-04 as the current chapter while pre-seeding the Black Wind North Path location, a state that represented the middle of the chapter rather than the actual post-Shared-04 state.

## What changed
- Corrected the fixture to represent the post-Shared-04 state: Shared-01..04 completed, Shared-05 current, timeline T120, Longma recruited, Longma memory unlocked, and current location BLACK_WIND_NORTH_PATH.
- Extended `combat/test_world_map_rumor_bounty_return.gd` after bounty victory and the production return-to-map button: click “返回行程”, verify the production Journey reloads Shared-05 and preserves the actual EAGLE_SORROW detour location, then use Journey Continue to start `SHARED-05-GAOJIAZHUANG-SEQUENCE`.
- Drives the Gaojiazhuang arrival dialogue and production Story MOVE, then validates GAOJIAZHUANG is saved before the recruitment choice, with timeline still T120 and Shared-01..04 completion history unchanged.

## Why
An optional branch should be escapable and should return to one fixed Journey. A test that stops at WorldMap return can miss a stale chapter cursor or a story continuation that incorrectly replays the previous chapter.

## Systems affected
- WorldMap → Journey scene return
- Shared-05 EventSequence continuation
- Canonical Story MOVE and persisted map location
- Optional bounty versus mainline invariants

## Files
- `combat/test_world_map_rumor_bounty_return.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-world-map-rumor-bounty-return.md`
- `docs/development_log/2026-10-11-world-map-bounty-return-to-shared05.md`

## Tests
- Extends an existing SceneTree entry; Runtime suite remains 43 registered entries.
- Verifies Shared-05 chapter/timeline/completed chapters/roster after optional bounty return.
- Uses the real Journey Continue action and Story MOVE transition; a fresh NarrativeManager reload must show GAOJIAZHUANG and unchanged timeline/progression.

## Godot Runtime status
**PENDING** — test the exact implementation SHA through Godot Runtime and Web Demo before recording this path as passed.

## Known issues
- The bounty fight's combat turns are still shortcut through the production victory callback, so this checks state/scene integration rather than manual combat input or encounter balance.
- Shared-05 is entered from the canonical post-Shared-04 save state; Wukong Origin and Shared-01..04 are separately covered by prior production scene smoke tests.

## Next step
After CI passes, review whether Shared-05/07 recruitment fights can also return to the WorldMap consistently after settlement, then move from framework validation to pacing / visual presentation of the first vertical slice.

## Handoff point
Optional detour return to Shared-05. Keep Story MOVE authoritative for canon location and leave free-travel graph guards intact.
