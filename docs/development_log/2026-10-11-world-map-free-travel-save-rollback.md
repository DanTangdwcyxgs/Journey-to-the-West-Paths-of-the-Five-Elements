# 2026-10-11 · WorldMap Free-Travel Save-Failure Rollback

## Goal
Make free map travel transactional in the same way as canonical story MOVE, so a failed save cannot leave the visible/current location ahead of persisted progress.

## Starting point
- Canonical Journey Story MOVE already snapshots NarrativeState and rolls back a failed save.
- `WorldMapScreen._travel()` previously mutated the current location with `WorldMapManager.visit()`, called `narrative.save()` without checking the return value, refreshed the UI, and unconditionally reported arrival.
- This meant the map could show a new current location and add it to visited history even though the save had rejected the movement.

## What changed
- `WorldMapScreen._travel()` now snapshots the complete serialized NarrativeState before travel.
- If the node is unreachable, no state is changed. If the node is reachable but save fails, the method restores the snapshot, refreshes the map, displays an explicit rollback message, and preserves the selected target so the player can retry.
- Added `combat/test_world_map_travel_save_failure_rollback.gd`. A controlled NarrativeManager first rejects the save, then accepts a retry from the same WorldMap travel button. The test verifies exact state rollback, old location, removal of the uncommitted visited-node entry, target availability, success feedback, and successful destination/history commit on retry.
- Registered the new SceneTree regression in `tests/runtime_suite.gd`.

## Why
Narrative locations and their visited history are part of the save state, not just map UI state. Free exploration must not have weaker persistence guarantees than Story MOVE, because both change the player's canonical current location.

## Systems affected
- WorldMapScreen free travel
- WorldMapManager visit result handling
- NarrativeState snapshot/restore and save boundary
- Godot Runtime regression suite

## Files
- `ui/world_map.gd`
- `combat/test_world_map_travel_save_failure_rollback.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-world-map-free-travel-save-rollback.md`

## Tests
- Runtime suite expected entries: 44.
- One forced-failure attempt must preserve the exact serialized state and remain retryable.
- A second successful attempt through the same UI button commits EAGLE_SORROW as current and visited.

## Godot Runtime status
**PENDING** — validate the exact implementation SHA with the Godot Runtime and Web Demo workflows before marking it green.

## Known issues
- The test controls the save return value and does not simulate file-system power loss mid-write.
- This change deliberately does not alter WorldMapManager's timeline, milestone, connection, or reachable-node rules.

## Next step
After CI passes, review the overall Wukong → Longma → Memory slice for remaining gameplay / presentation gaps instead of continuing framework-only work.

## Handoff point
Free WorldMap travel persistence. Keep NarrativeState authoritative and restore it on any failed save after a location mutation.
