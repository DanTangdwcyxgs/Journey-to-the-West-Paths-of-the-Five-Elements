# 2026-10-12 · Shared-02 Optional Rumor Access Before Eagle Sorrow

## Goal
Make the optional exploration explicitly promised by Shared-02 possible before the canonical Shared-03 Longma recruitment chapter, without changing the fixed Journey chronology.

## Finding
Shared-02 commits timeline 105. The production Shared-02 sequence tells players they can open the map to hear local rumors before continuing to Eagle Sorrow, but both the Eagle Sorrow WorldMap node and the Yellow Fang rumor required timeline 110. That made the optional detour unavailable until after the next mainline recruitment chapter.

## Changes
- Set the Eagle Sorrow exploration node threshold to timeline 105.
- Set only the optional Yellow Fang rumor threshold to timeline 105.
- Kept Shared-03 chapter/recruitment chronology at timeline 110.
- Added `combat/test_shared02_optional_rumor_access.gd`, which opens the production WorldMap from a saved post-Shared-02 fixture, travels using the real map control, hears the rumor, verifies bounty discovery and optional labeling, launches and wins the real optional bounty battle, returns to WorldMap, reloads the save, then returns to Journey and verifies Continue starts `SHARED-03-EAGLE-SORROW-SEQUENCE`.
- Updated `scripts/world/test_world_map_manager.gd` to use timeline 105 before checking Eagle Sorrow reachability.

## Why
The map affordance and narrative promise should match. This is an optional side detour at the existing world timeline, not a canonical chapter transition. The rumor and bounty do not recruit Longma or complete Shared-03.

## Files
- `data/world/world_map.json`
- `data/world/rumors.json`
- `scripts/world/test_world_map_manager.gd`
- `combat/test_shared02_optional_rumor_access.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`

## Validation
- Runtime suite entry count increases from 50 to 51.
- PASS: exact test head `529a9d2a2a24da5d55082078fcd3bc9e2aa515f8`; [Godot Runtime 38209253477](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38209253477) includes `PASS res://combat/test_shared02_optional_rumor_access.gd` and `RUNTIME_SUITE_PASS tests=51`.
- Web Demo is not run by this PR workflow; no feature-branch deployment claim is made.

## Next
Next, perform player-facing screenshot review and final character asset delivery. The repository currently contains six character SVG placeholders and no `assets/art/characters/final/` PNG/WebP assets. `ArtAssetCatalog` already supports final PNG/WebP overrides; use `docs/visual_reference/README.md` as the acceptance checklist.
