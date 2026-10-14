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
- Feature branch contains the production UI and registered SceneTree regression; expected suite is 52 entries. Base main Runtime / Web Demo are verified above; no feature-branch Web Demo deploy is claimed.
- Initial code head `842dccc14d7592574d98a2d471a830454067de05` failed during fixture setup: `NarrativeState.set_shared_chapter()` did not exist, and the child test hit its watchdog because the coroutine stopped before calling `quit()`. Fixed the API call to `set_current_shared_chapter()` and added diagnostic stage markers, a 45-second watchdog, and restoration of backed-up save/encounter files before watchdog exit. Failed run: [38496663446](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38496663446).
- Current implementation head `533ffa9eb989676a4cefc1e0bc9d85f81188cbce` passed exact-SHA Runtime [38496887862](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38496887862); the job log confirms `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=52`. No local Godot execution is claimed.
- Older heads `2a1dbc12d9f525e14f3c0fedc135f09af2d7e084` and `4d0a13a063ee5683b0e2cb9ab123579327db7be8` still show in-progress status and are stale; they are not evidence for or against this latest SHA.

## Known limitations
- Only Eagle Sorrow is configured as a region in this slice. Expand to other locations through data-driven definitions and content review rather than adding per-region one-off code.
- Points currently record clues and authored feedback only; they do not grant items, currency, bounties or chapter progress.
- No screenshot/pixel-art acceptance pass was run. Existing final transparent character PNG/WebP assets remain pending and SVG placeholders are not final art.

## Next step
PR #27 is open as Draft at https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/pull/27. The implementation head above is green at 52/52, but this documentation update creates a new head: require its exact-SHA Runtime to confirm `PASS res://combat/test_region_exploration.gd` and `RUNTIME_SUITE_PASS tests=52`. Then mark Ready, merge only the verified head, and validate merged main Runtime + Web Demo build/export/deploy.

## Handoff point
Start at the current PR head and its newest Runtime run. The key files are `ui/region_exploration.gd`, `scripts/world/region_exploration_manager.gd`, `scripts/narrative/narrative_state.gd`, and `combat/test_region_exploration.gd`. Keep optional region exploration separate from the fixed Shared chronology. After CI validation, continue region interaction/signposting and actual player-facing screenshot review, then deliver six separate final transparent pixel-art character assets through `ArtAssetCatalog`.
