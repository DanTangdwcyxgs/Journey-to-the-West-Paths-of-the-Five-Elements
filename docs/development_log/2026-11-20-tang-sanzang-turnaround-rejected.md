# 2026-11-20 — Tang Sanzang Turnaround Generation Rejected

## Goal

Generate the scheduled Tang Sanzang 2×2 four-view turnaround for the first playable character-art batch. The top-left front three-quarter view would become the 128×192 runtime crop only after every review gate passed.

## Generation record

- One image-generation call was made for the Tang Sanzang slot on 2026-11-20 (America/Los_Angeles).
- Intended subject: a calm, morally steady pilgrim; layered saffron/ochre and cream travel robes; restrained monk's staff or scripture detail; slim, recognizable pilgrim silhouette; same model, costume, standing pose, and equipment across four full-body rotations.
- Generated source: /mnt/data/a_clean_character_sheet_style_illustration_on_a_tr.png (conversation artifact; not copied into the repository).
- Format / dimensions: PNG, RGBA, 1254×1254.
- File size: 1,044,985 bytes.
- SHA-256: a294a1cb4efefc8d40193d11d1c7ca541efd97212cf62256291ba29fcdf02d0b.
- Alpha verification: extrema 0–255; 1,109,590 fully transparent pixels; 462,212 partially transparent pixels; all four image corners sample alpha=0. Native transparency is present. No painted checkerboard was detected.

## Review

### Critical failures

1. **Wrong medium:** the rendering is a smooth, detailed cel-shaded/anime illustration rather than deliberate pixel art with crisp clusters, stepped contours, and a consistent pixel scale. This fails the project's mandatory character-sprite medium gate.
2. **Wrong quadrant order:** generated lower row is rear view in bottom-left and left-facing profile in bottom-right. The contract requires rear three-quarter in bottom-right and left-facing profile in bottom-left.
3. **No safe transparent margins:** visible non-transparent pixels reach outer edges of all four quadrants. Edge-touching pixel counts:
   - TL: top 34, bottom 20, left 4, right 8
   - TR: top 29, bottom 65, left 3, right 0
   - BL: top 4, bottom 156, left 11, right 20
   - BR: top 16, bottom 110, left 4, right 0
   The source therefore cannot safely pass the canonical crop helper's edge/margin gate without modifying the generated source, which is not allowed for an unaccepted sheet.

### Additional design observation

- The headwear reads as a tall, ornate lotus/crown-like headdress. The brief allows approved monk headwear, but this particular royal-looking design has not been approved as the project's canonical Tang identity and should not be carried forward by assumption.

### Score (100-point rubric)

- Pixel craft / art direction: 3/25
- Identity / silhouette: 12/20
- Anatomy / pose / equipment: 11/15
- Multi-view consistency / composition: 7/15
- Palette / material readability: 7/10
- Canvas / transparency / delivery: 8/10
- Gameplay-scale readability: 2/5

**Total: 50/100 — REJECTED.** The three critical failures independently require rejection regardless of score.

## Decision

**REJECTED.** The native alpha is technically valid, but technical transparency cannot compensate for the incorrect art medium, view ordering, and lack of safe quadrant margins.

- The rejected output is retained only as the generated conversation artifact for owner inspection.
- It was not copied into the repository, archived under assets/art/source_sheets/, cropped, resized, cataloged, or placed in any production directory.
- No SVG fallback, AssetCatalog entry, game code, UI layout, or runtime asset was changed.
- No crop helper, Art Tooling workflow, Godot Runtime, Web Demo, or in-game screenshot review was run for this rejected output.

## Quota

- The single 2026-11-20 local-date generation call has been used.
- Do not make another image-generation call on this date, including an attempted correction.
- Keep the 2026-11-21 Bajie slot and later queue entries unchanged. The rejected Tang slot should be requeued only after the current first-batch integration / screenshot-review pause, rather than silently displacing the remaining scheduled characters.

## Next step

1. Continue non-generation work during the remainder of this local date.
2. Integrate the previously accepted Wukong source through the canonical binary handoff and tools/art/prepare_character_turnaround.py; do not confuse Wukong's accepted-for-integration status with production acceptance.
3. Complete exact-head Art Tooling / Godot Runtime and player-facing screenshot review for any integrated assets.
4. Requeue Tang after the first-batch integration checkpoint, using a stricter pixel-art-only prompt, explicitly locked lower-quadrant order, and larger transparent safety gutters.

## Handoff point

Art work remains on art/production-roadmap-2026-11-11, PR #30 open/Draft/unmerged. Start from the newest docs-synchronized art branch head. Main and the separate gameplay PR #34 remain untouched by this art rejection.
