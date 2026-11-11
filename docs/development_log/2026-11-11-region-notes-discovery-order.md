# 2026-11-11 · Region Notes Journal Discovery Order

## Goal
Make 「旅途见闻」 reflect the order in which the player actually discovered regional clues, rather than the order in which regions and points happen to be declared in the content catalog.

## Starting point
- Work continues on PR #29 branch `feature/black-wind-region-exploration-2026-10-14`; the PR remains open and unmerged.
- Before this change, the latest PR head `954562593ee6430dc3a37395aa9c390989f6a29f` passed Godot Runtime run [38522788993](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38522788993) with `RUNTIME_SUITE_PASS tests=54`.
- `NarrativeState.record_region_point_discovered()` appends a newly discovered point ID to `world_state.discovered_region_points`, rejects duplicate discoveries, and serializes/restores that array without sorting it. The persisted data already contains the required discovery order.

## Finding
`RegionExplorationManager.get_discovered_notes()` previously iterated `regions.values()` and then each region's authored points. That made the journal use catalog order, even when the player discovered clues in a different sequence.

## Changes
- Reordered the read-only projection to iterate the persisted discovery-ID array first, then resolve each known point against the region catalog.
- Kept undiscovered and unknown IDs out of the journal; duplicate IDs are handled defensively.
- Did not add a save field, timestamp, secondary journal store, reward, chapter mutation, or world-timeline change.
- Strengthened `combat/test_region_notes_log.gd`: the fixture discovers Black Wind first and Eagle Sorrow second, serializes/restores the state, then asserts both the data projection and production journal UI retain that order.

## Files changed
- `scripts/world/region_exploration_manager.gd`
- `combat/test_region_notes_log.gd`
- `docs/development_log/2026-11-11-region-notes-discovery-order.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Implementation commit: `525e069be678af344b723297c2f23e6f15c81379`.
- Regression commit: `bbdf5ee29f20157bc4f83c06380245ef71bf3cdf`.
- Godot Runtime for the regression head was triggered as run [42942960838](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42942960838); its status was **queued** when this record was written. This is not a Runtime pass. Recheck the final documentation-sync head and record its exact completed result before considering the batch validated.
- No Web Demo deploy, final character PNG/WebP delivery, or screenshot acceptance is claimed.

## Known limitations
- Discovery order is insertion order in the existing persisted ID array; no wall-clock timestamps are inferred or displayed.
- Journal content remains a read-only projection from the region catalog and only includes known discovered points.

## Next step / handoff
1. Check the exact newest PR #29 head's Godot Runtime result and inspect the job log for `PASS res://combat/test_region_notes_log.gd` and `RUNTIME_SUITE_PASS tests=54`.
2. If the exact head fails, fix the source/test issue and rerun; do not treat the previous PR head's success as validation of this change.
3. Keep PR #29 open and unmerged unless the project owner explicitly authorizes merging.
4. Continue to keep final transparent character assets and player-facing screenshot review separate from code/runtime acceptance.
