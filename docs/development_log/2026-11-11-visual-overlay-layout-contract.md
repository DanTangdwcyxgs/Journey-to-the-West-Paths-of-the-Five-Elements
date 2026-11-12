# 2026-11-11 · Visual Overlay Sprite Bounds and Ground Anchors

## Finding

A coordinate audit of `ui/visual_overlay.gd` against the fixed 1280×720 viewport and the exact character canvas contracts found two concrete presentation problems:

1. Personal-origin scenes drew a 128×192 character at 3.45× scale with its bottom anchor at 66% viewport height. The resulting 662px-tall canvas started about 187px above the viewport. The shadow and stage ground line were around 82–83% viewport height, leaving the sprite visibly detached from its ground anchor.
2. The Yellow Wind King battle-UI placement used a 2.65× scale and a 68% bottom anchor. Its 508.8px canvas started about 19px above the viewport, clipping the top of the boss canvas.

The separate Yellow Wind Ridge/Cave stage also placed the boss baseline much higher than the party baseline.

## Changes

- Added named presentation constants to `VisualOverlay` for origin hero scale/baseline/shadow and boss baselines.
- Origin hero scale is now 2.80× and the sprite bottom anchor aligns to the existing 82% ground line. The 128×192 character canvas now fits fully in the viewport; Longma's 160×128 canvas also remains fully visible.
- Kept the origin shadow close to the baseline (83% vs 82%) instead of more than 120px below the character canvas.
- Moved the Yellow Wind battle-UI boss baseline to 73%, giving its 2.65× canvas a safe top margin.
- Moved the Yellow Wind Ridge/Cave boss baseline to 77%, aligning its feet with the party staging area and preserving top/bottom margins.
- Added `combat/test_visual_overlay_layout_contract.gd`, which checks origin character bounds for all current origin characters, shadow/baseline distance, and both boss placements.
- Registered the new regression in `tests/runtime_suite.gd`.

## Files changed

- `ui/visual_overlay.gd`
- `combat/test_visual_overlay_layout_contract.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-11-11-visual-overlay-layout-contract.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation and limitations

The layout test is geometry-based at the canonical 1280×720 viewport and is part of the full Godot Runtime suite. It verifies the texture canvas bounds, not the opaque alpha bounds or final artistic balance of a future generated character. Player-facing screenshots are still required after actual image integration.

No image-generation call was made. No art asset or SVG fallback was modified. The daily generation allowance for 2026-11-11 remains consumed.

## Next step

After Wukong's 2026-11-12 source sheet is generated and cropped, inspect the actual main-menu and origin-route screenshots. If final art has different transparent padding, adjust visual presentation only after reviewing those screenshots, while preserving the exact runtime canvas contract.
