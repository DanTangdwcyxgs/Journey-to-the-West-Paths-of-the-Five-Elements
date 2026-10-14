# 2026-10-14 · Discovered Region Notes Journal

## Goal
Let players revisit clues after leaving a region, using the current save field rather than inventing a second journal persistence system.

## Architecture review
- `scripts/world/journey_log.gd` records battle results, defeated targets and world effects; it is not the region-clue source of truth.
- `NarrativeState.world_state.discovered_region_points` already persists clue point IDs and is intentionally flat. `RegionContentValidator` enforces globally unique point IDs.
- The journal is therefore a read-only projection of the existing region catalog plus the persisted discovery IDs.

## Changes
- Added `RegionExplorationManager.get_discovered_notes()`, which joins discovered IDs back to their region/point definitions and excludes undiscovered points.
- Added `ui/region_notes_log.gd` and `ui/region_notes_log.tscn`: a compact list/detail screen for recorded notes, an empty state, and a return-to-WorldMap action.
- Added a `旅途见闻` entry on WorldMap so the notes remain accessible after leaving a region.
- Added `combat/test_region_notes_log.gd` and registered it in `tests/runtime_suite.gd`. Coverage includes the production scene resource, cross-region aggregation, hidden undiscovered clues, save-state roundtrip, empty state, WorldMap entry point, and no mutation of timeline/chapter/recruitment/discovery state during review.
- Updated `docs/architecture.md`, this index, `docs/AI_MEMORY.md`, and `AI_HANDOFF.md`.

## Files changed
- `scripts/world/region_exploration_manager.gd`
- `ui/world_map.gd`
- `ui/region_notes_log.gd`
- `ui/region_notes_log.tscn`
- `combat/test_region_notes_log.gd`
- `tests/runtime_suite.gd`
- `docs/architecture.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-14-region-notes-index.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Runtime validation is pending for the initial implementation commit. Do not treat a queued or in-progress workflow as a pass; verify the exact branch head before marking this section complete.
- No visual screenshot acceptance, Web Demo deployment or final character PNG/WebP asset delivery is claimed.

## Known limitations
- The current discovery format stores IDs, not time/order metadata; the journal follows region-catalog order and does not infer timestamps.
- The screen intentionally does not expose undiscovered clues.

## Next step / Agent handoff
1. Inspect Godot Runtime for the exact feature commit; fix any parse, UI-construction or assertion failures and rerun.
2. After code/test success, sync the exact-head result into this log and the PR description, then check the documentation-sync head as well.
3. Keep PR #29 open and unmerged unless the user explicitly authorizes merge. Character PNG/WebP production and screenshot review remain separate.
