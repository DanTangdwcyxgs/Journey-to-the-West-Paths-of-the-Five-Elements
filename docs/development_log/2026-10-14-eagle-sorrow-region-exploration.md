# 2026-10-14 · Eagle Sorrow Region Exploration Vertical Slice

## Goal
Provide a first reusable region-entry and point-of-interest loop for the already-reachable Eagle Sorrow location. Discovery must persist across scene changes and save/reload, failed saves must roll back, and optional exploration must never advance the canonical Journey chronology.

## Starting point
- WorldMap offered free travel, rumors and optional bounties, plus a one-off Yellow Wind Ridge scene entry.
- There was no general data-driven region scene or persistent point-of-interest discovery contract.
- The project already treats NarrativeState as the authority for persistent world facts and requires state rollback when a save boundary fails.

## Changes in this batch
- Added `data/world/regions.json` with one initial region definition (`EAGLE_SORROW`) and three authored points of interest. This is a first slice, not a claim that all six map locations have bespoke exploration content.
- Added `scripts/world/region_exploration_manager.gd` for data loading, timeline/milestone/current-location gate checks, point lookup, and discovery decisions. The manager does not save or mutate the canonical Shared chapter.
- Extended `NarrativeState` with `discovered_region_points` and the explicit `record_region_point_discovered()` mutation method. The field is included in new-game initialization, world-state replacement, serialization and load migration (old saves default to an empty list).
- Added `ui/region_exploration.gd` and `ui/region_exploration.tscn`, including inspectable points, recorded/unrecorded status, a return-to-WorldMap control, and save-failure rollback/retry.
- Added a gated “进入区域：鹰愁涧 · 涧谷微探” button to WorldMap. It only appears when the current location has a region definition and is disabled unless the current location, timeline and milestones satisfy that region's gate.
- Added `combat/test_region_exploration.gd` and registered it in `tests/runtime_suite.gd`.

## Validation intent
The SceneTree regression exercises:
- Production WorldMap → region scene entry through the real button.
- Three-point data loading and discovery through the real inspect control.
- Discovery persistence through fresh NarrativeManager load and leaving/re-entering the region.
- Preservation of Shared chapter, global timeline, completed Shared history and recruited roster.
- Injected save failure that restores the complete NarrativeState snapshot, leaves the clue retryable and commits it after a successful retry.
- Rejection when the player is not at the configured WorldMap location.

## Files changed
- `data/world/regions.json`
- `scripts/world/region_exploration_manager.gd`
- `scripts/narrative/narrative_state.gd`
- `ui/world_map.gd`
- `ui/region_exploration.gd`
- `ui/region_exploration.tscn`
- `combat/test_region_exploration.gd`
- `tests/runtime_suite.gd`
- `docs/architecture.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `AI_HANDOFF.md`

## Baseline and validation status
- Base main SHA: `74c011680cc7a76afa478747475c9e3e8a0a40b2`.
- Base Godot Runtime [38495397569](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38495397569) passed with `RUNTIME_SUITE_PASS tests=51`.
- Base Web Demo [38495397529](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38495397529) passed build, Web export, Pages artifact upload and deployment. Published URL: https://dantangdwcyxgs.github.io/Journey-to-the-West-Paths-of-the-Five-Elements/
- Feature branch now contains new production UI and a registered SceneTree regression, so the expected suite becomes 52 entries. Exact-head Runtime is **pending**; no local Godot run is claimed and no feature-branch deploy is claimed.

## Known limitations
- Only Eagle Sorrow is configured as a region in this slice. Expand to other locations through data-driven definitions and content review rather than adding per-region one-off code.
- Points currently record clues and authored feedback only; they do not grant items, currency, bounties or chapter progress.
- No screenshot/pixel-art acceptance pass was run. Existing final transparent character PNG/WebP assets remain pending and SVG placeholders are not final art.

## Next step
Open a PR for this branch and inspect the latest exact-head Godot Runtime. Require `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=52`; fix any failures in the implementation/test rather than weakening invariant assertions. If green, merge and verify the merged main SHA's Runtime plus Web Demo build/export/deploy.

## Handoff point
Start at the current PR head and its newest Runtime run. The key files are `ui/region_exploration.gd`, `scripts/world/region_exploration_manager.gd`, `scripts/narrative/narrative_state.gd`, and `combat/test_region_exploration.gd`. Keep optional region exploration separate from the fixed Shared chronology. After CI validation, continue region interaction/signposting and actual player-facing screenshot review, then deliver six separate final transparent pixel-art character assets through `ArtAssetCatalog`.
