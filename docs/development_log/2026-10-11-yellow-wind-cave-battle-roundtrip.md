# 2026-10-11 · Yellow Wind Cave Battle Roundtrip

## Goal
Prove the graybox cave can move from its room progression into the normal encounter, return to the correct next room, resolve the Yellow Wind King, return to the safe cave exit, and exit back to Yellow Wind Ridge without altering the Shared Journey chronology.

## Starting point
- The Yellow Wind Ridge/Cave access and save-failure regression passed on exact commit `30f727d181df9b056c2abfb5e8731dcdd2e45840`: Runtime [38120240661](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120240661) passed 45/45, and Web Demo [38120240657](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120240657) build/deploy passed.
- Cave room progress is persisted through `YELLOW_WIND_CAVE_ROOM_<ROOM_ID>` markers in the NarrativeState rumor store.
- BattleUI returns normal encounter victories and completed cave bounty victories to `yellow_wind_cave.tscn`, but no one smoke proved that room cursor restoration and both return paths work together.

## What changed
- Added `combat/test_yellow_wind_cave_battle_roundtrip.gd`.
- Saves a canonical Shared-05 exploration fixture with Longma recruited, Yellow Wind Ridge milestones complete, cave gate opened, and CAVE_MOUTH/SAND_ALTAR recorded as completed.
- Starts the production cave scene, presses its normal-encounter action, enters the production BattleUI, invokes the production victory callback, and verifies the SANDSTORM_HALL completion marker persists without advancing Shared chapter/timeline/party.
- Uses the production Continue Exploration return button to reload the cave and verify the cursor moves to YELLOW_WIND_THRONE.
- Presses the actual Yellow Wind King battle button, verifies the canonical BOUNTY_YELLOW_FANG handoff, resolves victory through the production BattleUI callback, returns to the cave, verifies defeated-target journal state, preserved cave gate, no re-challenge action and safe exit feedback.
- Presses the production “返回黄风岭” control and verifies that Ridge can be re-opened from the authorized Black Wind North Path context.
- Backs up and restores NarrativeSave, active encounter handoff and pending resume files.

## Why
A cave is not playable if normal encounters return to the wrong room or a boss victory loses its exit state. This smoke covers the actual player-operated button/scene boundaries rather than only calling managers directly.

## Systems affected
- YellowWindCaveScreen exploration cursor
- BattleUI normal encounter victory handoff
- BountyRewardService / Yellow Wind King victory path
- Cave gate availability and safe exit feedback
- Save/load and the optional-route chronology invariants

## Files
- `combat/test_yellow_wind_cave_battle_roundtrip.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-yellow-wind-cave-battle-roundtrip.md`

## Tests
- Runtime suite expected registered entries: 46.
- Asserts real cave normal encounter → production BattleUI victory → correct cave room.
- Asserts real Yellow Wind King bounty → victory → safe cave exit → production Ridge return.
- Confirms Shared chapter, timeline, completed chapter history and recruited roster remain fixed throughout.

## Godot Runtime status
**PASS** — exact implementation commit `a552810c769bb2d0725a0edd4fade92a5386c2f0`. Godot Runtime run [38120481337](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481337) passed with `PASS res://combat/test_yellow_wind_cave_battle_roundtrip.gd` and `RUNTIME_SUITE_PASS tests=46`. Web Demo run [38120481282](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481282) completed successfully; both build and deploy jobs passed.

## Known issues
- Battle victory is shortcut through the production success callback rather than manual combat input, as in the established scene smoke conventions; this validates integration and progression, not combat balance.
- The BountyRewardService currently owns part of bounty reward application/save; if this smoke or follow-up forced-failure tests expose a split save boundary, that should be corrected before adding more dungeon mechanics.

## Next step
Bounty settlement is now transactional in `2026-10-11-bounty-settlement-atomic-retry.md`: Runtime 47/47 and Web Demo build/deploy passed on exact commit `3fd65d9f16453b6cb104ca249b4a87859e47895c`. Next add a production BattleUI regression for the “重试结算” path, then review side-route pacing/visual feedback.

## Handoff point
Yellow Wind Cave battle roundtrip. Do not alter the canonical Shared chapter or global timeline from optional exploration battles.
