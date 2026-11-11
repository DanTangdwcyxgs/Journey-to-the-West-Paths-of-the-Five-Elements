# 2026-11-11 · Daily AI Art Production Plan and Canvas Contract

## Goal
Create a reliable, one-image-per-day art-production process for the project's first final character and scene assets. Make the sequence, quality gates, dimensions, and next action recoverable by a future Agent without relying on this conversation.

## Starting point
- Main baseline: `395233d8bcaf13aa9022c33903ab03a75c5a83ae`.
- Existing delivery documents: `docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md`, `AI_ASSET_PIPELINE.md`, and `docs/visual_reference/README.md`.
- Six character resources are still SVG placeholders. `ArtAssetCatalog` already resolves final PNG → final WebP → SVG fallback.
- The visual reference audit requires six separate transparent character assets, then scene backgrounds. A contact sheet or planning infographic is not a shippable character asset.

## Today's generation record
- One image-generation call was used on 2026-11-11 to produce a 1536×1024 visual planning poster.
- The result contained inaccurate generated labels and character/asset assignments. It is not a production asset and is not authoritative documentation. It was not copied into the repository or the game asset folders.
- The daily generation allowance is considered consumed. No second generation call was made on 2026-11-11.
- No final PNG/WebP character or scene asset was accepted today. The first production generation is scheduled for 2026-11-12 (Wukong).

## Changes
- Added `docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md` as the canonical dated queue from 2026-11-12 through 2026-11-20.
- Scheduled one isolated image per local calendar day: Wukong, Tang, Bajie, Wujing, Longma, Yellow Wind King, Journey scenery, Yellow Wind battle background, and WorldMap background.
- Added an explicit one-call-per-day rule: rejected outputs are recorded, not retried the same day. The Agent continues with non-generation work after the daily image task.
- Audited `ui/visual_overlay.gd` and found that character draw size is computed from the raw texture width/height multiplied by presentation scale. The final image canvas must match the existing SVG dimensions exactly to avoid changing in-game character scale.
- Strengthened `combat/test_visual_asset_contract.gd` to enforce the expected canvas dimensions: Wukong/Tang/Bajie/Wujing 128×192, Longma 160×128, Yellow Wind King 144×192.

## Files changed
- `docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md`
- `docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md`
- `docs/visual_reference/AI_ASSET_PIPELINE.md`
- `docs/visual_reference/README.md`
- `combat/test_visual_asset_contract.gd`
- `docs/development_log/2026-11-11-ai-art-production-plan.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Runtime test change adds a size assertion against the currently selected texture for all six character IDs. Existing SVG fallbacks have the documented target dimensions.
- PASS: exact code + documentation head `5132ca55735cecf3f32b3c6ef2f402a954dd67c6`, Godot Runtime [42944345417](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42944345417), completed successfully. The job log confirms `PASS res://combat/test_visual_asset_contract.gd` and `RUNTIME_SUITE_PASS tests=52`. Any later documentation-only head must be checked against its own exact Runtime run.
- No final art asset, Web Demo deployment, or in-game screenshot acceptance is claimed.

## Known limitations
- Today's planning-poster generation did not produce a game-ready image. The next valid generation slot is 2026-11-12.
- Static art only is scheduled. Sprite animation, NPCs, regular enemies, props, and VFX remain deferred until the initial six-character and three-scene batch is integrated and reviewed.

## Next step / handoff
1. On 2026-11-12 local time, generate exactly one isolated Wukong full-body sprite with a transparent background and the approved character brief in the schedule.
2. Export/crop to exactly 128×192 with nearest-neighbor processing. Preserve the full staff, tail, feet, and silhouette.
3. Save to `assets/art/characters/final/wukong.png`; keep the SVG fallback untouched.
4. Update the daily schedule, a dated development log, AI memory, and handoff; then verify exact-head Godot Runtime.
5. Do not make any additional image-generation call on 2026-11-12. Use remaining work time for asset integration and other engineering tasks.
