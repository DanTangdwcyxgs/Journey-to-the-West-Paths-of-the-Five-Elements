# 2026-11-19 — Wukong Turnaround Generated and Accepted for Integration

## Goal

Use the single image-generation call for the requeued P0 Sun Wukong four-view turnaround. Review the actual PNG, not just the preview, and preserve the no-retry rule.

## Daily quota and source output

- Local date confirmed through the time service: 2026-11-19.
- Calls made: exactly one. No second call was made.
- Raw artifact: `wukong_turnaround_raw.png`.
- Source dimensions/format: 1536×1024 PNG RGBA.
- Raw SHA-256: `047c381b7b4e690c6180252ab764a5c4f73d1ca249b5915bae2ba7aac79ce3b5`.
- Raw file size: 1,886,063 bytes.
- Alpha channel: extrema (0, 254); fully transparent 1,110,183 pixels (70.6%); partially transparent 462,681; fully opaque 0. Sampled corners and empty gutters have alpha=0. This is actual file-level transparency; the preview's dark appearance is not a baked-in RGB background. No checkerboard pixels or scenery were detected.

## Layout and visual review

The 2×2 sheet matches the canonical order:

1. Top-left: canonical front three-quarter.
2. Top-right: right-facing profile.
3. Bottom-right: rear three-quarter.
4. Bottom-left: left-facing profile.

All four views depict the same monkey-king model and share scale, baseline, palette, costume, headband, staff design, and standing pose. The simian muzzle/ears and golden brow fillet read clearly. Red/vermilion/ochre clothing and the Ruyi Jingu Bang identify the character. The monkey tail is present and visibly separated from legs and staff in all views. Both feet and both staff ends are inside their quadrants. There are no labels, dividers, captions, UI, watermark, or scenery.

The staff remains in the same anatomical right hand as the character rotates. The canonical front view places this hand on the viewer-left, which is correct for the chosen front-facing orientation. The prompt had ambiguous wording between "image-right" and "anatomical right"; `prompts/2026-11-12-wukong-turnaround.md` has been clarified to prioritize anatomical right and explicitly explain viewer-left placement in the front view.

## Alpha cleanup and crop-contract preview

The untouched raw PNG was retained separately. A processed duplicate, `wukong_turnaround_alpha_cleaned_v2.png`, clears only alpha value 1 to fully transparent. This removes extremely faint background-edge noise without changing any pixel whose alpha is 2–254 or altering RGB values.

- Processed copy SHA-256: `086e37efa11f2aee0bece45f21c5b9ad9a1e83ff2b7dc9ed662d823d7f3b37cb`.
- Processed copy size: 1,758,586 bytes.
- Fully transparent ratios after cleanup: front 72.94%, right 74.91%, rear 72.12%, left 74.10%.
- All four quadrant alpha bounds are inset from each quadrant's outer edges; each quadrant exceeds the required 5% fully transparent margin by a wide margin.
- A crop-contract preview was calculated using the canonical top-left extraction, 4 px target padding, proportional fit, bottom alignment, and nearest-neighbor resizing. Preview: 128×192 RGBA; placed sprite size 120×160; alpha bounds (4, 29, 124, 188).
- Crop preview SHA-256: `e437b3f01387a029b7967273b2bca234f304a7adbd9c2926dc8a3c7bad2411de`.

The exact repository `prepare_character_turnaround.py` script was inspected to confirm its alpha, quadrant, inset, and crop contracts. The repository checkout was not available in the execution container, so the canonical script itself was **not executed**. The alpha/bounds validation and crop calculation were independently replicated for inspection only. Do not claim canonical tool execution.

## Art-review score

- Pixel craft / art direction: 21/25
- Identity / silhouette: 20/20
- Anatomy / pose / equipment: 14/15
- Multi-view consistency / composition: 14/15
- Palette / material readability: 9/10
- Canvas / transparency / delivery: 8/10
- Gameplay-scale readability: 4/5

**Total: 90/100. Decision: ACCEPTED FOR INTEGRATION.**

This is not `PRODUCTION ACCEPTED`. The source PNG and processed copy exist as conversation artifacts, but no PNG binary has been committed to the art branch. No source-sheet archive, runtime crop, catalog integration, Art Tooling, Godot Runtime, Web Demo, or in-game screenshot validation has been completed by this generation review.

## Required next integration steps

1. Hand off the processed RGBA source PNG to the art branch without overwriting the raw original.
2. Run `python tools/art/prepare_character_turnaround.py --input <processed_source> --character wukong` from the repository root, without `--overwrite`.
3. Inspect the generated repository source archive and exact 128×192 runtime crop; compare the crop to the preview, including tail, feet, headband, and full staff.
4. Commit the source sheet and runtime crop to `assets/art/source_sheets/characters/wukong_turnaround.png` and `assets/art/characters/final/wukong.png`.
5. Run exact-head Art Tooling and Godot Runtime; then inspect actual Journey/battle screenshots at game scale. Only then advance the decision state beyond Accepted for Integration.
6. The daily image-generation quota is consumed for 2026-11-19. Do not regenerate or retry today. The next scheduled one-call asset is Tang Sanzang on 2026-11-20.

## Repository changes in this round

- Updated `docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md` with the generation record and today's accepted-for-integration state.
- Clarified the Wukong staff/hand wording in `docs/visual_reference/prompts/2026-11-12-wukong-turnaround.md`.
- Added this log and indexed it.
- Updated AI memory and handoff.
- No gameplay code, ArtAssetCatalog, source-sheet binary, runtime crop, scene asset, or runtime contract changed.