# 2026-10-11 · Story MOVE → World Map Persistence

## Goal
Connect the Shared-04 story movement beat to the existing WorldMap exploration state and UI.

## Starting point
- Production Shared-04 sequence contains `MOVE(map_id="WORLD_MAP", marker_id="BLACK_WIND_NORTH_PATH")`.
- Journey displayed a travel transition, waited 0.28s, then advanced the EventSession immediately. It never called `WorldActionService.apply_move()`, so the player reached the next dialogue but their actual WorldMap current location stayed wherever it had previously been.
- The existing WorldMap UI already reads `NarrativeState.world_state.current_location`, calculates connected reachable nodes, persists free travel through `WorldMapManager.visit()`, and saves those visits.

## What changed
- Journey now commits story movement after the transition animation by taking a pre-move NarrativeState snapshot, calling `WorldActionService.apply_move()`, and saving.
- EventSession advances past MOVE only after the movement record is valid and the save succeeds. Invalid move data or a save failure leaves the MOVE action retryable; save failure restores the full pre-move NarrativeState.
- Added `combat/test_shared_story_move_world_map.gd` and registered it in the Runtime suite.
- The test starts from a canonical Shared-04 saved prerequisite state, uses production MainMenu Continue, traverses the actual Shared-04 EventSequence to MOVE, then verifies Black Wind North Path is persisted as visited/discovered/current.
- It opens the production WorldMap through the real Journey map button, asserts the UI reflects Black Wind North Path and lists connected Eagle Sorrow as reachable, then uses the actual Travel button and reloads to verify the Eagle Sorrow visit persisted.

## Why
A story move must establish the canonical place where optional exploration begins. Keeping the map UI separate from narrative progression is useful, but the story still needs to commit the location transition before players can explore nearby nodes.

## Systems affected
- Journey EventSequence MOVE handling
- WorldActionService / NarrativeState.world_state
- WorldMapManager reachable-node graph
- WorldMapScreen current-location and travel UI

## Files
- `ui/journey.gd`
- `combat/test_shared_story_move_world_map.gd`
- `tests/runtime_suite.gd`
- `docs/architecture.md`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-story-move-world-map.md`

## Tests
- New SceneTree smoke verifies story MOVE → saved current location → real WorldMap UI → free travel to a connected node → save/load persistence.
- Existing WorldActionService unit test remains and continues to verify the canonical state mutation.
- Expected registered Runtime suite entries: 40.

## Godot Runtime status
**PASS** — exact implementation commit `0aa7d6bffb22c03d05f51d95a09ee3e57f1927d5`. Godot Runtime run [38116737816](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737816) passed with `PASS res://combat/test_shared_story_move_world_map.gd` and `RUNTIME_SUITE_PASS tests=40`. Web Demo run [38116737826](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38116737826) build and deploy passed.

## Known issues
- The smoke starts at a valid saved Shared-04 prerequisite state rather than replaying all earlier Wukong/Longma chapters. Earlier entries are covered by the MainMenu, Origin handoff and Shared-03 recruitment scene smokes.
- WorldMap travel remains restricted to reachable nodes and required milestones; this change does not bypass those checks.
- A dedicated failure-injected MOVE save rollback is the next batch and is tracked in `2026-10-11-story-move-save-failure-rollback.md`.

## Next step
After CI passes, add a direct movement-save failure test if warranted, then test how optional rumors and bounties branch from Black Wind North Path without advancing the canonical Shared chapter.

## Handoff point
Narrative MOVE commit boundary. Do not let story progression skip the location persistence, and do not let WorldMap free travel bypass milestone/connection rules.
