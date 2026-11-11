# PixelHUD Theme Refresh on Scene Re-instancing

## Goal

Ensure a newly instantiated scene root receives the PixelUI theme even when its scene file path matches the previous scene.

## What changed

- PixelHUD now tracks `current_scene.get_instance_id()` in addition to `scene_file_path`.
- Reapply `PixelUI.build_theme()` when either path or scene instance identity changes.
- Record empty path and instance ID 0 when `current_scene` is null during a transition.
- Add four scene-theme identity regression assertions to the existing VisualOverlay layout contract test.

## Why

PixelHUD previously returned early whenever the scene file path was unchanged. Re-instancing the same scene path could therefore leave a new root Control without the theme normally applied by PixelHUD. This was the same path-only lifecycle weakness found in VisualOverlay.

## Systems affected

Presentation theme assignment only. No gameplay, narrative, combat, save, or control input behavior changes.

## Files

- ui/pixel_hud.gd
- combat/test_visual_overlay_layout_contract.gd
- docs/AI_MEMORY.md
- docs/development_log/README.md
- AI_HANDOFF.md

## Tests

- Same path + new instance: refresh theme.
- Same path + same instance: do not refresh.
- Current scene null: clear tracked identity.
- Null-to-scene entry: refresh theme.
- Existing VisualOverlay backdrop opacity and scene identity tests remain in the same Runtime suite.

## Godot Runtime status

Exact-head Godot Runtime and Art Tooling Actions must pass before this change is considered validated.

## Known issues

No player-visible screenshot acceptance has been performed. Final production art assets remain pending.

## Next step

Continue runtime UI layering and lifecycle audit. Capture/inspect actual scene screenshots after production art integration.

## Handoff point

Inspect ui/pixel_hud.gd::_process_scene() and combat/test_visual_overlay_layout_contract.gd. Preserve path + instance identity checks on any further persistent UI autoloads.
