# 2026-11-11 · Journey Overlay Refresh on Origin Completion

## Finding

The persistent `VisualBackdrop` autoload previously queued a redraw only when `current_scene.scene_file_path` changed. Origin-route completion happens inside the existing `journey.tscn` scene: `NarrativeManager` changes the starting character's `route_progress` to `COMPLETE`, and `JourneyScreen` refreshes its UI without changing scenes.

The backdrop therefore had no invalidation signal for the switch from the single-origin-hero stage to the post-origin party stage. Depending on when the last redraw occurred, the single hero could remain visible after the save had already entered the shared journey.

## Changes

- Added a presentation signature to `VisualOverlay`.
- For `journey.tscn`, the signature includes scene path, starting character, and that character's route status.
- For other scenes, the signature remains the scene path only.
- On a signature change, the overlay refreshes scene visuals when the scene path changed and always queues a redraw.
- Added regression checks to `combat/test_visual_overlay_layout_contract.gd` verifying that:
  - an origin-route status transition changes the Journey signature;
  - a starting-character change changes the Journey signature;
  - route status does not cause unrelated main-menu signature churn.

## Files changed

- `ui/visual_overlay.gd`
- `combat/test_visual_overlay_layout_contract.gd`
- `docs/development_log/2026-11-11-journey-overlay-origin-refresh.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation

The new signature assertions are part of the existing VisualOverlay layout regression and the full Godot Runtime suite. Exact-head Godot Runtime and Art Tooling must both pass before treating this change as validated.

No gameplay progression or save data behavior was changed. No image-generation call or art asset modification was made. The 2026-11-11 image-generation allowance remains consumed.

## Next step

After the first final character assets are integrated, capture the main-menu, origin Journey, completed-origin Journey, battle, and WorldMap screens. This automated signature regression proves invalidation logic, not visual screenshot acceptance.
