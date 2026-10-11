# 2026-10-11 · CJK Font Fallback / Runtime Resource Contract

## Goal
Remove the missing-font error without pretending the project always has local font assets, and ensure CI tests the same CJK font setup used by the Web Demo.

## What changed
- Added `PixelUI.load_ui_font(resource_path = FONT_PATH)`. It uses the bundled font when the resource exists and otherwise safely returns Godot's engine fallback font.
- `PixelHUD._ready()` now uses the shared resolver rather than directly loading a potentially missing path.
- The Godot Runtime workflow downloads `NotoSansSC-Regular.otf` before Godot imports assets, mirroring the Web Demo workflow.
- Added `combat/test_pixel_ui_font_contract.gd`, testing a deliberately missing font path, the default Theme font, and PixelHUD initialization.
- Added the new test to `tests/runtime_suite.gd`; suite size increased from 31 to 32.
- Added `/fonts/` to `.gitignore` so locally downloaded font files do not get committed inadvertently.
- Updated the END-feedback log with its actual validation status, updated this log index, and refreshed `docs/AI_MEMORY.md` / `AI_HANDOFF.md`.

## Why
The font error was a genuine resource-contract issue, while Resource/RID teardown diagnostics are separate. Runtime should remain safe when running without the optional CJK font; CI/Web builds should still explicitly prepare the intended CJK font.

## Systems affected
- Presentation font loading (`PixelUI`, `PixelHUD`)
- Godot Runtime build environment
- Headless UI fallback regression
- Engineering memory / handoff

## Files
- `ui/pixel_ui.gd`
- `ui/pixel_hud.gd`
- `.github/workflows/godot-runtime.yml`
- `tests/runtime_suite.gd`
- `combat/test_pixel_ui_font_contract.gd`
- `.gitignore`
- `docs/development_log/2026-10-11-cjk-font-fallback-runtime-contract.md`
- `docs/development_log/2026-10-11-journey-end-chapter-completion-feedback.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- Godot Runtime workflow [38103113032](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103113032): **PASS**, `RUNTIME_SUITE_PASS tests=32`.
- Web Demo workflow [38103113019](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103113019): **PASS**.
- Runtime log no longer contains `Resource file not found: res://fonts/NotoSansSC-Regular.otf`.

## Remaining issues
- Runtime still reports teardown diagnostics: leaked Canvas, CanvasItem, Viewport, TextServer resources / RIDs, plus ObjectDB instances and resources in use at exit. The suite passes, but these diagnostics are not considered resolved.
- The engine fallback keeps missing-font execution safe; when the CJK font file is absent, the fallback is not guaranteed to provide full Chinese glyph coverage. Build workflows explicitly download the intended font.
- Final character PNG/WebP still do not exist because image generation was blocked by the Free-plan limit. This is tracked separately and does not block framework work.

## Next step
Add broader SceneTree smoke coverage for Main Menu → Journey → EventSequence → Battle / END → Save. Then isolate teardown warnings by identifying which same-process test retains viewport / CanvasItem / shaped-text resources.

## Handoff point
Presentation resources / CI font provisioning. Keep font-file distribution and image art separate from Narrative / Domain rules.
