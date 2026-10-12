# 2026-10-12 · Separate Optional Yellow Fang Bounty from Mainline Yellow Wind King

## Goal
Ensure an optional early bounty cannot mark the later Yellow Wind Cave mainline boss as already defeated.

## Starting point
- The optional rumor at Eagle Sorrow discovers `BOUNTY_YELLOW_FANG`.
- The Yellow Wind Cave boss entrance also started `BOUNTY_YELLOW_FANG`, and `YellowWindCaveScreen._is_boss_defeated()` checked that same journal ID.
- Therefore defeating the optional Yellow Fang bounty first could suppress the required Yellow Wind King encounter. The bounty catalog also mislabeled the optional target as “黄风妖王” instead of the rumor's “黄牙老妖”.

## What changed
- Kept `BOUNTY_YELLOW_FANG` as the optional bounty identity and renamed its player-facing title to “黄牙老妖”.
- Added a distinct `YELLOW_WIND_KING` mainline boss definition, named “黄风妖王”, with its own encounter/journal ID and mainline status.
- Changed the cave's defeat gate and boss handoff to use `YELLOW_WIND_KING`; optional bounty completion no longer closes the cave boss gate.
- Extended the production cave battle roundtrip fixture to start with the optional bounty already defeated, assert the mainline boss remains available, and assert mainline victory records only `YELLOW_WIND_KING`.
- Updated the WorldMap production smoke to assert the optional bounty is displayed as “黄牙老妖”.

## Why
A side objective and a canonical story boss are separate gameplay facts even if they share thematic roots. They must not share identity keys for persistence, gating, rewards, or battle journal records.

## Systems affected
- Bounty definitions and player-facing names
- Yellow Wind Cave boss gating and battle handoff
- Production WorldMap and cave SceneTree regressions

## Files
- `data/world/bounties.json`
- `ui/yellow_wind_cave.gd`
- `combat/test_yellow_wind_cave_battle_roundtrip.gd`
- `combat/test_world_map_rumor_bounty_return.gd`
- `tests/runtime_suite.gd` (existing registration reused)
- `docs/development_log/README.md`
- `docs/development_log/2026-10-12-yellow-wind-bounty-mainline-identity.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- Production cave roundtrip preloads a defeated `BOUNTY_YELLOW_FANG` and proves `YELLOW_WIND_KING` is still available.
- After mainline victory, the journal must contain `YELLOW_WIND_KING` and preserve the existing chronology/party assertions.
- WorldMap rumor-to-bounty smoke verifies the optional target's correct name.

## Godot Runtime status
**PENDING** — the exact feature-branch head must pass Godot Runtime before this batch is considered complete.

## Web Demo status
Not run on feature branches by workflow design; check the main branch after merge.

## Known issues
- Existing saves that already contain `BOUNTY_YELLOW_FANG` as defeated will now correctly treat only the optional target as defeated. A mainline boss defeated in an older save under the shared legacy ID may require a migration if such saves exist in active use.

## Next step
Run exact-head Godot Runtime, inspect the two affected SceneTree tests, then update the handoff and PR validation record before marking it ready.
