# 2026-10-11 · WorldMap Rumor → Optional Bounty → Return

## Goal
Verify the optional exploration branch from Black Wind North Path through an Eagle Sorrow rumor, into a bounty fight, then back to the same WorldMap location without changing the canonical Shared Journey.

## Starting point
- Shared-04 story MOVE → WorldMap current location passed on commit `0aa7d6bffb22c03d05f51d95a09ee3e57f1927d5`: Runtime [38116737816](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737816) 40/40 and Web Demo [38116737826](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737826) build/deploy passed.
- The follow-up forced MOVE save-failure rollback passed on commit `1b84b1abcf668b9d2d96412822fa00c7a43a9ecc`: Runtime [38116864150](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116864150) 41/41, Web Demo [38116864144](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116864144) build/deploy passed.
- WorldMapManager already supported the service logic to travel between reachable nodes and hear rumors, while WorldMapScreen and BattleUI had production rumor→bounty→return controls; this end-to-end loop was not covered by the runtime SceneTree suite.

## What changed
- Added `combat/test_world_map_rumor_bounty_return.gd` and registered it in the Runtime suite.
- Starts from the persisted Black Wind North Path with canonical Wukong milestone and Shared-04 current chapter, opens production WorldMapScreen, travels to Eagle Sorrow, hears the Yellow Fang rumor, and validates bounty discovery persisted.
- Enters the production BattleUI via the real bounty button, resolves victory through the existing production callback, and presses the actual return-to-map control.
- Verifies the player returns to Eagle Sorrow, defeated-target journal prevents a repeat bounty, rumor discovery and saved location remain intact, and active/pending handoff files are cleared.
- Asserts optional bounty completion does not alter current shared chapter, global timeline, completed shared chapters or recruited roster.

## Why
The map should provide meaningful optional content without quietly advancing the required pilgrimage. End-to-end validation is needed to ensure the rumour discovery, battle entry, reward commit, map return and mainline invariants work together.

## Systems affected
- WorldMapScreen travel and rumor controls
- BountyEncounterState → BattleUI transition
- BountyRewardService / JourneyLog persistence
- Optional progression versus canonical Shared Journey

## Files
- `combat/test_world_map_rumor_bounty_return.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-story-move-save-failure-rollback.md`
- `docs/development_log/2026-10-11-world-map-rumor-bounty-return.md`

## Tests
- Runtime smoke verifies the production WorldMap → rumor → BattleUI → WorldMap chain.
- Canonical chapter, timeline, completed-chapter list and recruited roster are snapshot-compared around the optional bounty branch.
- Runtime suite expected registered entries: 42.

## Godot Runtime status
**PASS** — exact implementation commit `d387b16ab7af58fb4e841a257c6c053e430056f4`. Godot Runtime run [38117052682](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117052682) passed with `PASS res://combat/test_world_map_rumor_bounty_return.gd` and `RUNTIME_SUITE_PASS tests=42`. Web Demo run [38117052652](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117052652) build and deploy both passed.

## Known issues
- Battle turns are shortcut by calling the production victory callback; this smoke tests scene integration and progression semantics, not combat balance or manual player input.
- The current bounty scene uses the existing Yellow Wind boss runtime for the Yellow Fang bounty; this matches the first currently implemented optional bounty but should be generalized before exposing different bounty bosses through the same UI.

## Next step
After CI passes, evaluate the optional branch's return path to the Shared-04 story and the next mainline chapter; then continue the Wukong → Longma vertical slice pacing review.

## Handoff point
Optional exploration must stay a branch within the fixed Journey, never a separate campaign or an implicit Shared chapter completion.
