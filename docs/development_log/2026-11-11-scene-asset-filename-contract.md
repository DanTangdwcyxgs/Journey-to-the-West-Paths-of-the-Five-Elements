# 2026-11-11 · Scene Asset Filename Contract and Runtime Validation

## Finding

A cross-check of the production schedule against `scripts/presentation/art_asset_catalog.gd` found that the scene output filenames did not match the catalog's generic ID-to-lowercase resolver:
- Schedule: `journey_scenery.png`; old catalog candidate: `journey.png`.
- Schedule: `yellow_wind_battle.png`; old catalog candidate: `battle_yellow_wind.png`.
- Schedule: `world_map.png`; old catalog candidate already matched.

The first two generated backgrounds would therefore remain unused and the runtime would silently keep loading the SVG fallback, even if the planned PNG files were delivered correctly.

## Implementation

- Added explicit `SCENE_FINAL_STEMS` mapping in `ArtAssetCatalog`:
  - `JOURNEY` → `journey_scenery`
  - `BATTLE_YELLOW_WIND` → `yellow_wind_battle`
  - `WORLD_MAP` → `world_map`
- Kept all existing SVG fallback paths unchanged.
- Preserved PNG → WebP → SVG resolution order.
- Updated `combat/test_art_asset_catalog.gd` to validate the documented scene stems, the actual resolved path/priority, successful texture loading, and exact 16:9 scene texture ratio.
- Updated `AI_ASSET_DELIVERY_SPEC.md` with the authoritative scene ID-to-filename table.

## Why 16:9 is enforced

`VisualOverlay` draws each scene texture across its full control rect. The production brief and current fallback backgrounds are 16:9, so new final scene assets must preserve that ratio rather than be stretched or cropped unexpectedly.

## Files changed

- `scripts/presentation/art_asset_catalog.gd`
- `combat/test_art_asset_catalog.gd`
- `docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md`
- `docs/development_log/2026-11-11-scene-asset-filename-contract.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation

The runtime suite includes `combat/test_art_asset_catalog.gd`; the new checks execute in the normal Godot Runtime CI. The exact updated branch head must pass Godot Runtime before this fix is marked validated. Art Tooling remains independent and is re-run for the exact same head.

No image-generation call was made. No final art assets or SVG fallbacks were modified. The 2026-11-11 image-generation allowance remains consumed.

## Next step

On 2026-11-12, generate the Wukong turnaround exactly once, inspect the original source sheet, crop the top-left view, and verify that the final PNG is selected by the catalog with the correct 128×192 canvas. The first scene asset scheduled for 2026-11-18 must be saved using the now-explicit catalog filename mapping.
