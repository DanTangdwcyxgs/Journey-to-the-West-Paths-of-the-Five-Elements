# VisualOverlay Scene Instance Refresh

## Goal

Ensure the persistent VisualOverlay autoload reapplies scene presentation when a scene is recreated, including when the replacement uses the exact same .tscn path.

## What changed

- Track the current scene root instance ID in addition to scene_file_path.
- Reapply the stage texture and backdrop ColorRect policy whenever either the scene path or root instance identity changes.
- Clear the previous scene identity, path, backdrop texture, and presentation signature while current_scene is null during a transition.
- Add a pure should_reapply_scene_visuals() policy and three regression cases.

## Why

The previous path-only comparison could miss a re-instantiated scene with the same path. A new root Control would not receive the backdrop ColorRect opacity adjustment, while the overlay could continue treating it as the prior scene instance. This is an edge case for same-scene reload/re-entry and scene replacement paths.

## Systems affected

Presentation lifecycle only. Gameplay, narrative state, combat, save data, and input routing are unchanged.

## Files

- ui/visual_overlay.gd
- combat/test_visual_overlay_layout_contract.gd
- docs/AI_MEMORY.md
- docs/development_log/README.md
- AI_HANDOFF.md

## Tests

- Same scene path + different instance ID must reapply scene visuals.
- Same path + same instance ID must not reapply scene visuals.
- Different path must reapply scene visuals.
- Existing backdrop opacity, 12-scene routing, Journey signature, sprite bounds, and boss layout assertions remain registered.

## Godot Runtime status

Exact-head CI is required. Do not reuse the prior opacity-guard SHA result as validation for this follow-up.

## Known issues

No player-facing screenshot acceptance has been performed. Production art assets are still pending scheduled generation and visual review.

## Next step

Continue checking scene lifecycle and HUD layering in actual runtime, then perform screenshot acceptance after production sprites and stage images are integrated.

## Handoff point

Inspect ui/visual_overlay.gd::_process() and combat/test_visual_overlay_layout_contract.gd. Preserve both scene path and scene instance identity in future refresh changes.
