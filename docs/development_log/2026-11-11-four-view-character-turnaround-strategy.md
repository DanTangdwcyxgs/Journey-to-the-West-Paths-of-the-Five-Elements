# 2026-11-11 · Four-View Character Turnaround Strategy

## Decision

The initial art queue planned one isolated pose per character for each daily image-generation call. After reviewing the actual runtime consumers (ui/visual_overlay.gd and ui/character_portrait.gd), the character texture is currently used as a static presentation image; the game does not yet switch among directional frames or play character sprite animations.

A single direction would satisfy the current runtime, but it would leave three quarters of each character's design unexplored and provide no consistent rear/side references for future work. The revised plan uses each character's one daily generation call for a complete four-view turnaround sheet, while keeping the runtime texture contract unchanged.

## Four-view layout

One character per sheet, arranged in a 2×2 grid in clockwise orientation order:

1. Top-left: primary front three-quarter battle-ready view. This is the canonical crop for the current game.
2. Top-right: right-facing side profile.
3. Bottom-right: rear three-quarter view.
4. Bottom-left: left-facing side profile.

All four must show the full character, including signature equipment and extremities, with consistent anatomy, costume, colors, proportions, and props. The sheet must have a transparent background and contain no UI, labels, panel borders, watermark, unrelated character, or scenery. This is a single-character model turnaround, not a multi-character contact sheet.

## Source and runtime file separation

- Archive the untouched source sheet at assets/art/source_sheets/characters/<id>_turnaround.png.
- Crop only the top-left three-quarter view to assets/art/characters/final/<id>.png.
- Preserve the exact runtime crop dimensions: Wukong/Tang/Bajie/Wujing 128×192; Longma 160×128; Yellow Wind King 144×192.
- Preserve the character aspect ratio and use nearest-neighbor processing only. Do not squeeze four directions into one runtime texture.
- The other three views remain available as design references for future direction-specific assets and animations. They are not currently loaded by ArtAssetCatalog.

## Why this fits the current game

- Current VisualOverlay and CharacterPortrait consumers need one clear static sprite today; they do not consume directional animation frames.
- The top-left three-quarter view gives the current game a clear, readable battle/journey presentation.
- Side and rear views make later animation, back-of-costume detailing, and new presentation angles more consistent without spending an extra image-generation call for basic turnaround references.
- Scene slots remain one image per scene; their composition is not changed.

## Schedule and current status

- 2026-11-11's only image-generation call was already consumed by the rejected planning poster. No second call is permitted today.
- 2026-11-12 remains the first production slot: Wukong four-view turnaround sheet, then the canonical top-left crop.
- Remaining character dates and the three scene dates remain unchanged.
- This document strategy supersedes the earlier single-pose-only brief in the initial 2026-11-11 plan.

## Files updated

- docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md
- docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md
- docs/visual_reference/AI_ASSET_PIPELINE.md
- docs/visual_reference/README.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Validation and limitations

- Documentation-only strategy revision; no gameplay, resource catalog, or runtime code was changed.
- The existing visual-contract test continues to validate the final runtime crop size only.
- No new Runtime result is claimed for this documentation revision until the exact updated branch head completes CI.
- No character art was generated or accepted in this revision.

## Next Agent

On 2026-11-12 local time, use exactly one generation call for Wukong's transparent 2×2 four-view turnaround sheet. Inspect all views, archive the original, crop the top-left primary three-quarter view into the exact 128×192 runtime canvas, then update the schedule, dated log, AI memory, and handoff. Do not retry image generation on the same local date.
