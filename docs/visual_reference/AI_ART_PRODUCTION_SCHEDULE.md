# Daily AI Art Production Schedule

> Canonical source of truth for the daily image-generation queue. This file takes precedence over any generated planning poster, chat image, or informal message. Mandatory visual acceptance rules: [ART_REVIEW_STANDARD.md](ART_REVIEW_STANDARD.md).

## 1. Operating rules

- Every asset must pass [ART_REVIEW_STANDARD.md](ART_REVIEW_STANDARD.md): all critical gates plus a score of at least 90/100. Prompt similarity, technical validity, or passing CI alone never constitutes aesthetic acceptance.
- Record prompt compliance, native-resolution inspection, gameplay-scale inspection, integration verification, and player-facing screenshot review separately. Any critical failure means `REJECTED`; do not archive/crop/catalog it.

- The project owner has a limit of **one image-generation call per local calendar day**. Use the owner's local date in `America/Los_Angeles`.
- Before generating, read this schedule and the current visual contract. Check today's status first. **Never make a second image-generation call on the same date**, even to fix a weak or incorrect result.
- Each character slot uses its one daily generation call to produce one coherent four-view turnaround sheet for that character. This is not a multi-character contact sheet: it contains the same character in four complete orientations. Each scene slot still produces one full scene background.
- If the output misses the brief, lacks real transparency, contains text/UI/watermarks, or cannot meet the required canvas ratio, mark it `REJECTED`; do not retry that day. Use the rest of the day for cropping/inspection, code, tests, documentation, or other non-generation work. Replan the missed asset to the next available generation date.
- Do not assume background work will occur automatically. The next Agent should execute only the task for the current date, then update this schedule and the development log before moving on.
- A generated image is not accepted merely because it exists. It must pass the visual checklist, canvas-size contract, catalog lookup, exact-head Godot Runtime, and actual in-game screenshot review before being called production-ready.

## 2. Today's generation record — 2026-11-11

**Status: REJECTED AS A GAME ASSET / DAILY GENERATION BUDGET CONSUMED**

One 1536×1024 image-generation call produced a visual art-production planning poster. It is only a rough layout concept: its generated day labels and character/asset names do not accurately match this project's production plan. It must not be committed as a game asset, used as the canonical schedule, cropped into production files, or treated as evidence that any character/background is complete.

No production character or scene asset was accepted today. Do not call image generation again on 2026-11-11. The first production asset is scheduled for 2026-11-12.



### Execution record — 2026-11-12

**Status: REJECTED / DAILY GENERATION BUDGET CONSUMED — NO PRODUCTION ASSET ACCEPTED**

One image-generation call produced a 1536×1024 RGBA four-view Wukong concept sheet. The file has a real alpha channel and transparent background; transparency itself passed inspection. The image is not accepted because the rendering is soft, painterly/highly anti-aliased rather than the required crisp pixel-art clusters, Wukong's required monkey tail is not visibly represented in the views, and the staff is carried diagonally across/behind the shoulders rather than upright beside the body in the same neutral pose and grip across all views. The design therefore fails core identity/pose requirements despite having four recognizable orientations.

The generated image was inspected in-session and was not added to the repository. No source-sheet archive, runtime crop, catalog change, or player-facing asset was created. Do not retry on 2026-11-12. The Wukong slot is rescheduled to 2026-11-13; shift the remaining queue by one day to preserve order. Continue non-generation work for the rest of 2026-11-12.
## 3. Production queue

| Date (local) | One image to generate | Required output / file | Status |
|---|---|---|---|
| 2026-11-13 | Sun Wukong four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/wukong_turnaround.png` → `assets/art/characters/final/wukong.png` · 128×192 | Pending |
| 2026-11-14 | Tang Sanzang four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/tang_turnaround.png` → `assets/art/characters/final/tang.png` · 128×192 | Pending |
| 2026-11-15 | Zhu Bajie four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/bajie_turnaround.png` → `assets/art/characters/final/bajie.png` · 128×192 | Pending |
| 2026-11-16 | Sha Wujing four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/wujing_turnaround.png` → `assets/art/characters/final/wujing.png` · 128×192 | Pending |
| 2026-11-17 | Bai Longma four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/longma_turnaround.png` → `assets/art/characters/final/longma.png` · 160×128 | Pending |
| 2026-11-18 | Yellow Wind King four-view turnaround sheet + canonical game crop | `assets/art/source_sheets/characters/yellow_wind_turnaround.png` → `assets/art/characters/final/yellow_wind.png` · 144×192 | Pending |
| 2026-11-19 | Main Journey scenery background | `assets/art/scenes/final/journey_scenery.png` · 16:9 | Pending |
| 2026-11-20 | Yellow Wind battle background | `assets/art/scenes/final/yellow_wind_battle.png` · 16:9 | Pending |
| 2026-11-21 | World map background | `assets/art/scenes/final/world_map.png` · 16:9 | Pending |

After 2026-11-20, pause new image generation long enough to integrate the first batch, verify the Godot/Web build, and inspect the actual main-menu, Journey, battle, and WorldMap screenshots. Only then schedule NPC, enemy, prop, VFX, and animation assets. Static character and scene assets come first; animation is explicitly later in the delivery spec.

## 4. Per-asset art briefs

### Shared four-view layout for every character slot

Generate one transparent-background 2×2 turnaround sheet, containing the same single character in four complete full-body orientations. Keep anatomy, costume, colors, face, markings, accessories, weapon design, and proportions consistent across all four views. Use the exact same standing, battle-ready pose and weapon grip in every quadrant; rotate the model around its vertical axis instead of inventing four different action poses. No view may be cropped or overlap another. Each figure should occupy most of its quadrant height while leaving safe transparent margins around every extremity and prop.

Use this clockwise quadrant order:
- Top-left: primary front three-quarter view, subtly turned toward the viewer; this is the canonical game-sprite crop.
- Top-right: right-facing side profile.
- Bottom-right: rear three-quarter view.
- Bottom-left: left-facing side profile.

All four views must be large, fully visible from head to foot/hoof/tail/weapon tip, and clearly separated by empty transparent space. No panel borders, labels, letters, numbers, text, watermark, UI, scenery, ground plane, or painted checkerboard. Do not create four different costume interpretations. Preserve crisp, intentional pixel clusters and a consistent pixel scale in all quadrants.

Archive the untouched source sheet at assets/art/source_sheets/characters/<id>_turnaround.png. Crop only the top-left three-quarter view into the matching assets/art/characters/final/<id>.png file. The other three views remain as model-reference material for future direction-specific sprites and animation; do not shrink all four views into the single runtime texture.

### 2026-11-12 / rescheduled 2026-11-13 — Wukong
- Copy-ready detailed prompt: [2026-11-12 Wukong Four-View Turnaround](prompts/2026-11-12-wukong-turnaround.md). Use this exact brief for the single scheduled generation call.
- Four-view turnaround of the same agile monkey king. The top-left view uses the neutral, upright battle-ready stance in the dedicated prompt: shoulder-width footing, relaxed knees, and an upright torso with subtle agile readiness. Hold the Ruyi Jingu Bang upright beside the body at a slight natural angle in the same anatomical right hand and grip across all four views; do not swing, thrust, or raise it into a separate action pose.
- Every view must retain the expressive simian face and muzzle, golden headband, red/ochre armor and cloth, recognizable staff, and visible tail. Rotate the staff and tail naturally with the body; do not hide them behind the silhouette.
- Keep staff, tail, both feet, and headband fully inside every relevant view. He must read immediately as Sun Wukong, not a human general.
- Canonical crop: exact 128×192 final canvas.

### 2026-11-13 — Tang Sanzang
- Four-view turnaround of the same calm, morally steady pilgrim. The top-left view is a dignified, travel-ready three-quarter pose, not a spell-casting wizard pose.
- Preserve the canonical monk identity in every view: clean shaved head or approved monk headwear, layered saffron/ochre kasaya and travel robe, restrained scripture scroll or monk's staff, slim silhouette.
- Make robe layering and silhouette readable from front, side, and back. Keep hands, robe hem, footwear, and any scripture/staff fully visible.
- Canonical crop: exact 128×192 final canvas.

### 2026-11-14 — Zhu Bajie
- Four-view turnaround of the same heavy-set, powerful pig demon. The top-left view should feel sturdy and battle-ready while retaining warmth and comic personality.
- Preserve a clear pig-head silhouette, snout, tusks, ears, rounded strong body, dark earth-tone travel clothing, and unmistakable nine-toothed rake in all views.
- Ensure the rake head, ears, belly silhouette, feet, and clothing layers remain fully visible. He must not become childish or mascot-like.
- Canonical crop: exact 128×192 final canvas.

### 2026-11-15 — Sha Wujing
- Four-view turnaround of the same tall, broad, dependable river-sand warrior. The top-left view should feel quiet, grounded, and ready for battle.
- Preserve the sand/water-blue-grey palette, rugged travel gear or restrained armor, recognizable beard/hair/beads, and crescent-moon spade / monk's spade in all views.
- Differentiate his tall, stable silhouette from Bajie's broad rounded silhouette. Keep spade blade, hair, beads, feet, and garment edges fully visible.
- Canonical crop: exact 128×192 final canvas.

### 2026-11-16 — Bai Longma
- Four-view turnaround of the same horizontal quadruped dragon-horse; do not force Longma into a humanoid pose.
- The top-left view is a clear front three-quarter quadruped stance. The remaining views show right-side, rear three-quarter, and left-side anatomy.
- Preserve a white horse body with unmistakable Eastern dragon ancestry: subtle horns, scaled details, flowing mane, expressive dragon-like face, four legs/hooves, and a long readable tail. Keep the body horizontal and all legs anatomically consistent.
- Canonical crop: exact 160×128 final canvas.

### 2026-11-17 — Yellow Wind King
- Four-view turnaround of the same imposing Yellow Wind King boss. The top-left view should read as a threatening, battle-ready boss with a strong silhouette.
- Preserve the yellow/ochre/brown wind-demon identity, readable weasel/marten-like demon face, layered robes/armor, and controlled sand/wind motifs in every view. Do not make him a generic wolf or human soldier.
- Keep ears, muzzle, robe/armor edges, feet, and any held weapon fully visible in all orientations. His silhouette must feel larger and more imposing than a common enemy.
- Canonical crop: exact 144×192 final canvas. If a larger boss presentation is needed, change presentation scale in code deliberately rather than silently changing texture canvas.

### 2026-11-18 — Journey scenery
- One wide 16:9 playable background, ideally 1920×1080 or the largest available 16:9 output.
- Distinct far mountains/ridges, a distant Chinese temple or settlement, mid-ground cliffs/road, readable foreground standing area, foliage, and small warm lantern/light sources.
- Match the project's block-constructed, intimate dusk/summer-evening emotional north star. Use depth layers and a clear stage for the characters.
- No character sprites, HUD, labels, text, menus, logos, or watermark.

### 2026-11-19 — Yellow Wind battle environment
- One wide 16:9 battle-stage background, ideally 1920×1080 or the largest available 16:9 output.
- Left side must leave clear space for the party; right side must leave space for the boss/enemies; central space stays readable for skills and VFX.
- Use distant ridges, sandstorm depth, ruined fortress/temple shapes, a distinct battle floor, subtle ember cracks, and a wind-vortex focal area without cluttering the combatants.
- No sprites, HUD, labels, text, health bars, menus, or watermark.

### 2026-11-20 — World map background
- One wide map-style/isometric 16:9 composition.
- Readable Chinese mythological landmarks, mountains, river, village/temple silhouettes and paths. Keep open, low-detail space where the game can draw node markers and routes.
- Do not bake in location names, route text, UI pins, menus, or a legend. The game owns all labels and route state.

## 5. Hard technical contract — source sheet versus gameplay crop

The four-view source sheet is archival reference material and is not loaded by `ArtAssetCatalog`. Only the top-left primary three-quarter view is cropped into the final gameplay sprite. The current `ui/visual_overlay.gd` draws that final texture using its raw width and height multiplied by a per-character presentation scale, so the final crop must exactly match the current SVG fallback dimensions:

| Character | Canvas |
|---|---:|
| Wukong | 128×192 |
| Tang | 128×192 |
| Bajie | 128×192 |
| Wujing | 128×192 |
| Longma | 160×128 |
| Yellow Wind King | 144×192 |

Preserve the untouched four-view image at assets/art/source_sheets/characters/<id>_turnaround.png. Crop the top-left view without cutting its silhouette, then fit it proportionally inside the exact final canvas; never stretch the character to fill the canvas. Use nearest-neighbor scaling only; do not introduce blur/anti-aliasing. Keep transparent padding consistent and keep feet/hooves, weapon, tail, and headwear inside the final crop. The source sheet itself is not subject to the 128×192 / 160×128 / 144×192 runtime-size assertion.

The exact-size contract is also enforced by `combat/test_visual_asset_contract.gd`. If a deliberate future change requires different dimensions, update `VisualOverlay`, all dependent layouts, and the regression in the same reviewed change.

## 6. Daily post-generation checklist

For each generated asset, the Agent must:

1. Inspect all four views at native size. Confirm they are the same character model, all full-body, consistently proportioned, correctly oriented, and free of overlap or cropped extremities.
2. Confirm transparent alpha; no checkerboard painted into the image. Reject a sheet that contains text, labels, borders, UI, scenery, or watermarks.
3. Keep the generated PNG unchanged at its original input path until the preparation tool completes; do not manually crop, resize, or recompress it.
4. Run `python tools/art/prepare_character_turnaround.py --input /absolute/path/<id>_turnaround.png --character <id>` from the repository root. The tool first confirms all four quadrants contain visible pixels, transparent margin, and no edge-touching crop, then byte-for-byte archives the source, extracts the top-left primary view, and writes the exact-size runtime crop with aspect ratio preserved and nearest-neighbor scaling.
5. Inspect the tool output and the resulting crop visually at native and in-game scale. The tool cannot verify that all four views depict the same model, costume, stance, or weapon grip; human review remains mandatory.
6. Keep the SVG fallback untouched. Do not use `--overwrite` unless the previous sheet and crop have been reviewed and replacement is intentional.
7. Add a dated development log with the prompt summary, output dimensions, processing steps, file SHA/path, and acceptance/rejection result.
8. Run exact-head Godot Runtime CI. Inspect the log for `PASS res://combat/test_visual_asset_contract.gd` and the full `RUNTIME_SUITE_PASS` result. Do not claim success from a queued/in-progress run.
9. Update this schedule, `docs/AI_MEMORY.md`, `AI_HANDOFF.md`, and the development-log index.
10. After the character/background batch is complete, run Web Demo build/deploy and inspect actual game screenshots. Resource-load CI alone is not aesthetic acceptance.
11. Once today's image task is done, continue with non-generation work. Do not spend another generation call for the same local date.

## 7. Non-generation work to do between scheduled images

Until the next calendar day, continue useful work without another image-generation call:
- Verify the four-view turnaround source, alpha, and final top-left crop. Prefer the deterministic helper in `tools/art/prepare_character_turnaround.py`; refine only with local image processing and never another generation call that day.
- Run `python -m unittest discover -s tools/art -p 'test_*.py' -v` when changing the crop helper.
- Check catalog paths and pixel filtering; preserve nearest-neighbor rendering.
- Improve screenshot capture/review and the visual acceptance checklist.
- Audit current SVG fallbacks and scenes without reworking game logic.
- Update source docs and handoff records; run Runtime/Web CI when there is a meaningful change.
- Keep the six SVG fallbacks and all game logic intact until final assets pass review.

## 8. Authority and status

- This schedule is the canonical daily queue. Generated schedule graphics are inspiration only and never override this Markdown.
- A planned asset is not complete until the file exists at the specified path and passes the required review/CI gates.
- The 2026-11-11 planning-poster generation and 2026-11-12 Wukong generation are explicitly rejected as production assets. Wukong's next scheduled attempt is 2026-11-13; a planned slot is not a delivered asset.
