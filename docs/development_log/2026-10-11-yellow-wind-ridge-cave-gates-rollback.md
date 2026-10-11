# 2026-10-11 · Yellow Wind Ridge / Cave Stage Gate and Save Rollback

## Goal
Make the Yellow Wind Ridge side route actually enterable from Black Wind North Path, protect canonical stage order, and use reliable save/rollback boundaries before moving through the graybox cave.

## Starting point
- The first Wukong → Longma → Memory vertical slice is green on commit `b4aa8ef0515354d12705cedd5715bd5321415e30`: Runtime [38119684898](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684898) passed 44/44 and Web Demo [38119684880](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38119684880) build/deploy passed.
- `YellowWindRidgeScreen` called manager methods `is_available`, `get_current_stage`, and `get_stage`, but `YellowWindRidgeManager` did not implement them. Future stage rows were selectable even before prior milestones completed.
- Ridge stage completion and cave room progression mutated NarrativeState then ignored save failures, so visible stage/room cursors could move ahead of saved progress.
- Cave entry had no authoritative gate check in its own `_ready()`, so loading the scene directly could bypass the ridge entrance.

## What changed
- Implemented Ridge availability, current stage, stage lookup and sequence gating in `YellowWindRidgeManager`. Availability is based on the timeline, current Black Wind North Path location, and Longma recruitment milestone.
- Only the current or already-reached ridge stages can be selected; future stages render as locked and redirect to the current stage if clicked.
- Choice/event completion snapshots the full NarrativeState and only advances after a successful save. Save failure restores the full state and leaves the same action retryable.
- Opening the Yellow Wind Cave commits `YELLOW_WIND_GATE_OPEN` before changing scenes. The gate remains the current stage until the Yellow Wind King is defeated, allowing the player to return to an already-open cave without repeating earlier ridge steps.
- Cave entry validates both the saved gate milestone and current location; direct unauthorized entry is rejected.
- Cave room progress and SAND_ALTAR choice use state snapshots and restore both NarrativeState and `current_room_index` after save failure.
- Added `combat/test_yellow_wind_ridge_cave_progression.gd` and registered it in the Runtime suite.

## Why
These controls form the next part of the first Vertical Slice. A UI that references missing manager methods or permits stage skipping is not a playable side route; ignored save errors can also strand the player in a room/phase the save does not recognize.

## Systems affected
- YellowWindRidgeManager
- YellowWindRidgeScreen stage and gate controls
- YellowWindCaveScreen gate, room progress and choice persistence
- Save failure rollback and retry
- Godot Runtime SceneTree regression suite

## Files
- `scripts/world/yellow_wind_ridge_manager.gd`
- `ui/yellow_wind_ridge.gd`
- `ui/yellow_wind_cave.gd`
- `combat/test_yellow_wind_ridge_cave_progression.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-yellow-wind-ridge-cave-gates-rollback.md`

## Tests
- Runtime suite expected registered entries: 45.
- Tests stage gating and current-stage progression.
- Tests failed and successful retry for RIDGE_ENTRY choice, ABANDONED_INN event, cave-gate save and CAVE_MOUTH/SAND_ALTAR progress.
- Tests that the cave cannot be entered directly before the saved gate is opened.

## Godot Runtime status
**PENDING** — run Godot Runtime and Web Demo on the exact implementation SHA before marking this batch green.

## Known issues
- This batch does not yet run a fully interactive Yellow Wind Cave battle route in one smoke. Existing BattleUI supports returning normal encounters to the cave and persists a cave-room completion marker on victory; the boss route still requires a dedicated scene smoke.
- Boss battle turns remain outside this test; this is progression/access/persistence validation rather than combat balance.

## Next step
After this batch passes, add a production scene smoke through the cave's normal encounter → return → Yellow Wind King battle → return, then evaluate side-story pacing/feedback before adding more systems.

## Handoff point
Yellow Wind Ridge and Cave progression gates. Keep Yellow Wind Ridge optional: it must not advance the canonical Shared Journey chapter or timeline by itself.
