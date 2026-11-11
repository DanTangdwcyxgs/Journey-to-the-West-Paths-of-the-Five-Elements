# 2026-10-14 · Region Content Catalog Validation

## Goal
Raise the content quality gate for data-driven optional regions before more locations are authored. Prevent malformed region JSON, broken map references, ambiguous location ownership, unusable clue records, and duplicate persisted clue identifiers from silently entering the runtime catalog.

## Starting point
- Current region catalog includes Eagle Sorrow, Five Elements Mountain and Black Wind North Path.
- `RegionExplorationManager` can reject empty or duplicate region IDs while loading, but the catalog contract did not comprehensively check region locations, clue IDs, gate fields, or player-facing clue text.
- `NarrativeState.world_state.discovered_region_points` stores point IDs without a region namespace. Reusing a point ID in a different region would incorrectly cause one clue discovery to mark another clue as discovered.
- The last verified PR #29 head before this batch was `fcba52ed18c3d65c24ac220d46d78d819f852ee3`, Runtime [38501734471](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38501734471), 52/52.

## Changes
- Added `scripts/world/region_content_validator.gd` with a reusable `validate_payload(region_payload, world_map_payload)` contract.
- The validator checks JSON-root shapes, unique world node IDs, non-empty and unique region IDs, real map-location references, one region per map location, region titles/descriptions, non-negative integral timeline gates, array-shaped non-empty/unique milestone IDs, non-empty point arrays, globally unique clue IDs, and required clue name/description/result text.
- Numeric timeline validation accepts both integer and whole-number floating-point values returned by Godot's JSON parser, while rejecting negative and fractional gates.
- Added `combat/test_region_content_validator.gd` and registered it in `tests/runtime_suite.gd`.
- Negative fixtures cover unknown map locations, duplicate region IDs, multiple regions claiming one location, point ID collision across regions, missing clue feedback, negative/fractional timelines, repeated milestone IDs, and empty point lists. The current production catalog is also validated by the same contract.

## Files changed
- `scripts/world/region_content_validator.gd`
- `combat/test_region_content_validator.gd`
- `tests/runtime_suite.gd`
- `docs/architecture.md`
- `docs/development_log/2026-10-14-region-content-validation.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/2026-10-14-region-entry-feedback.md`

## Validation
- First attempt SHA `c10d46cb7c2056017ef4f9481591de0cd93eafff` failed Runtime [38502308548](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502308548): strict `TYPE_INT` checking rejected valid timeline values read from JSON. This was a validator assumption bug, not a production content defect.
- Corrected validator/test head `22e83daf31ca7176dc9d120595306e9bdab092ad` passed Runtime [38502403071](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502403071), `PASS res://combat/test_region_content_validator.gd`, `RUNTIME_SUITE_PASS tests=53`.
- Latest implementation/test head `da48a2b8fd4e00df8dd4d3ba1c1a47ce33b582aa` also passed Runtime [38502420049](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38502420049), including the additional duplicate-region, fractional-timeline and repeated-milestone cases, with `RUNTIME_SUITE_PASS tests=53`.
- The current change remains in PR #29 and has not been merged. No image generation, Web Demo deployment or visual screenshot acceptance is claimed.

## Known limitations
- The validator is enforced through CI/runtime tests; it is not invoked as a costly full-catalog validation on every region screen entry.
- This batch validates region content and cross-references; it does not validate final art assets or map screenshots.

## Next step / Agent handoff
1. Add a compact player-facing journal/index for already discovered region clues so players can review notes after leaving a region. Inspect the existing `JourneyLog` and persistence contracts first to avoid duplicating the source of truth.
2. Keep clue discoveries optional and separate from rewards, completed chapters, recruitment and the fixed Journey timeline.
3. Continue to keep PR #29 open unless the user explicitly authorizes merge. Final transparent character PNG/WebP assets and visual screenshot acceptance remain a separate pending deliverable.
