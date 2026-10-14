# 2026-10-14 · Five Elements Mountain Region Exploration

## Goal
Expand the reusable region-exploration flow from one configured map location to two. Five Elements Mountain must use the existing data-driven region contract, current-location + timeline + milestone gates, persisted clue discovery, and the same production screen. Optional exploration must not grant rewards or change Journey chronology / recruited party / completed chapters.

## Starting point
- Mainline commit `ccc44e226bab2e722fb4413c55f698db9e69cd2f` included Eagle Sorrow's reusable exploration screen and three clue points, along with persistent discovery state and failure rollback.
- The post-merge docs-only main commit Runtime [38497385618](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385618) passed; Web Demo [38497385698](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385698) passed build/export/Pages deploy.
- The established contract is data-driven: add a region definition rather than bespoke location-specific scene logic.

## Changes in this batch
- Added `FIVE_ELEMENTS_MOUNTAIN` to `data/world/regions.json` with required timeline 100, required milestone `WUKONG_RECRUITED`, and three clue-only points:
  - `FIVE_ELEMENTS_MOUNTAIN_OLD_STELE` / 山门旧碑
  - `FIVE_ELEMENTS_MOUNTAIN_SEAL_SCAR` / 封缚石痕
  - `FIVE_ELEMENTS_MOUNTAIN_PILGRIM_OFFERING` / 松下行脚包
- Reused `RegionExplorationManager` and `RegionExplorationScreen`; no special-case scene or region-specific UI code was added.
- Expanded `combat/test_region_exploration.gd` to test the mountain definition, current-location gate, timeline gate, milestone gate, production map travel from Eagle Sorrow to Five Elements Mountain, regional UI entry, three rendered clues, discovery persistence across save/reload, returning to the map, and returning to Eagle Sorrow for the existing save-failure rollback test.
- The smoke continues to assert that clue discovery leaves the canonical Shared chapter pointer, global timeline, completed chapter lists, and recruited roster unchanged.

## Files changed
- `data/world/regions.json`
- `combat/test_region_exploration.gd`
- `docs/development_log/2026-10-14-five-elements-mountain-region.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Base main SHA: `ccc44e226bab2e722fb4413c55f698db9e69cd2f`; base Runtime [38497385618](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385618) and Web Demo [38497385698](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497385698) both passed.
- Code head `eaa86b236188eeb9189304994849756ecb27dc2c` passed exact-head Godot Runtime [38497613436](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38497613436): `RUNTIME_SUITE_PASS tests=52`.
- This change has not been merged. Documentation synchronization will create a new exact head, which must also pass Runtime before PR #28 is marked Ready. No Web Demo deployment for the feature branch is claimed.

## Known limitations
- Only two map locations have region definitions: Eagle Sorrow and Five Elements Mountain. The other map locations still need content review and region definitions before they can expose the generic entry.
- Points are observations only; they do not grant items, currency, bounty, or chapter progress.
- Player-facing screenshot / art acceptance remains outstanding. Existing SVG placeholders are not final transparent character assets.

## Next step
PR #28 is open as Draft: https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/pull/28. Require the newest exact-head Runtime to report `RUNTIME_SUITE_PASS tests=52` and ensure the region SceneTree regression exits without errors/timeouts. After exact-head success, mark Ready, merge using the verified SHA, and validate the merged main SHA's Runtime + Web Demo build/export/Pages deploy.

## Handoff point
Start from PR #28's newest head and Runtime run. The primary implementation points are `data/world/regions.json`, `scripts/world/region_exploration_manager.gd`, `ui/region_exploration.gd`, and `combat/test_region_exploration.gd`. Continue by adding additional locations as data-only configurations wherever possible; preserve location/timeline/milestone gates, unique persisted discoveries, save rollback, and the fixed Journey chronology.
