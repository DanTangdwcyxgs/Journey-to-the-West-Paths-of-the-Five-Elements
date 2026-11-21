# VisualOverlay Backdrop Opacity Guard

## Goal

Prevent unsupported scenes or scenes with missing stage art from having their solid UI backgrounds accidentally made translucent by the always-on VisualOverlay autoload.

## What changed

- Added VisualOverlay.background_color_for_backdrop(color, backdrop_available).
- Full-screen root ColorRect nodes are now alpha-capped only when the current scene actually loaded a stage texture.
- If the current scene has no mapped stage, or the mapped stage texture is unavailable, the original background color is preserved.
- Existing translucent shades remain at their authored alpha rather than being forced to a lower opacity.
- Added three regression assertions to combat/test_visual_overlay_layout_contract.gd.

## Why

The overlay previously capped every large root ColorRect at 0.30 alpha regardless of whether an underlay texture existed. That made screens such as Camp, Shop, Party, Preparation, and unsupported future scenes partially transparent even though no stage art was being drawn behind them.

## Systems affected

Presentation only: VisualOverlay backdrop compositing. No changes to gameplay state, combat, narrative progression, save data, or asset files.

## Files

- ui/visual_overlay.gd
- combat/test_visual_overlay_layout_contract.gd
- docs/AI_MEMORY.md
- docs/development_log/README.md
- AI_HANDOFF.md

## Tests

- No loaded stage texture: opaque background color remains unchanged.
- Loaded stage texture: full-opacity background alpha is capped at 0.30.
- Existing translucent shade alpha (0.12) remains unchanged.
- Existing 12-scene stage routing and all prior layout/signature checks remain in the same Runtime suite.

## Godot Runtime status

The regression is registered in the existing Godot Runtime suite. Exact-head Actions verification is required after this commit; the final run IDs and result will be recorded in PR #30.

## Known issues

No player-visible screenshot acceptance has been performed. The final production art assets are still pending their scheduled daily generation/review.

## Next step

Continue auditing runtime presentation layer ordering and input behavior, then inspect actual scene screenshots after the final art assets are integrated.

## Handoff point

Start with ui/visual_overlay.gd and combat/test_visual_overlay_layout_contract.gd. The alpha clamp now depends on background_texture != null; do not reintroduce unconditional ColorRect transparency changes.
