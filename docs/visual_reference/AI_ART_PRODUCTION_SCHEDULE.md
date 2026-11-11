# Daily AI Art Production Schedule

> Canonical source of truth for the daily image-generation queue. This file takes precedence over any generated planning poster, chat image, or informal message.

## 1. Operating rules

- The project owner has a limit of **one image-generation call per local calendar day**. Use the owner's local date in `America/Los_Angeles`.
- Before generating, read this schedule and the current visual contract. Check today's status first. **Never make a second image-generation call on the same date**, even to fix a weak or incorrect result.
- Each scheduled image should produce one isolated, production-oriented asset. Do not put multiple unrelated deliverables into a contact sheet.
- If the output misses the brief, lacks real transparency, contains text/UI/watermarks, or cannot meet the required canvas ratio, mark it `REJECTED`; do not retry that day. Use the rest of the day for cropping/inspection, code, tests, documentation, or other non-generation work. Replan the missed asset to the next available generation date.
- Do not assume background work will occur automatically. The next Agent should execute only the task for the current date, then update this schedule and the development log before moving on.
- A generated image is not accepted merely because it exists. It must pass the visual checklist, canvas-size contract, catalog lookup, exact-head Godot Runtime, and actual in-game screenshot review before being called production-ready.

## 2. Today's generation record — 2026-11-11

**Status: REJECTED AS A GAME ASSET / DAILY GENERATION BUDGET CONSUMED**

One 1536×1024 image-generation call produced a visual art-production planning poster. It is only a rough layout concept: its generated day labels and character/asset names do not accurately match this project's production plan. It must not be committed as a game asset, used as the canonical schedule, cropped into production files, or treated as evidence that any character/background is complete.

No production character or scene asset was accepted today. Do not call image generation again on 2026-11-11. The first production asset is scheduled for 2026-11-12.

## 3. Production queue

| Date (local) | One image to generate | Required output / file | Status |
|---|---|---|---|
| 2026-11-12 | Sun Wukong full-body character sprite | `assets/art/characters/final/wukong.png` · 128×192 | Pending |
| 2026-11-13 | Tang Sanzang full-body character sprite | `assets/art/characters/final/tang.png` · 128×192 | Pending |
| 2026-11-14 | Zhu Bajie full-body character sprite | `assets/art/characters/final/bajie.png` · 128×192 | Pending |
| 2026-11-15 | Sha Wujing full-body character sprite | `assets/art/characters/final/wujing.png` · 128×192 | Pending |
| 2026-11-16 | Bai Longma horizontal dragon-horse sprite | `assets/art/characters/final/longma.png` · 160×128 | Pending |
| 2026-11-17 | Yellow Wind King boss sprite | `assets/art/characters/final/yellow_wind.png` · 144×192 | Pending |
| 2026-11-18 | Main Journey scenery background | `assets/art/scenes/final/journey_scenery.png` · 16:9 | Pending |
| 2026-11-19 | Yellow Wind battle background | `assets/art/scenes/final/yellow_wind_battle.png` · 16:9 | Pending |
| 2026-11-20 | World map background | `assets/art/scenes/final/world_map.png` · 16:9 | Pending |

After 2026-11-20, pause new image generation long enough to integrate the first batch, verify the Godot/Web build, and inspect the actual main-menu, Journey, battle, and WorldMap screenshots. Only then schedule NPC, enemy, prop, VFX, and animation assets. Static character and scene assets come first; animation is explicitly later in the delivery spec.

## 4. Per-asset art briefs

### 2026-11-12 — Wukong
- One isolated, complete, 3/4 battle-ready full-body sprite; transparent background.
- Must read immediately as a monkey king, not a human general: expressive simian face/muzzle, golden headband, red/ochre armor and cloth, recognizable Ruyi Jingu Bang, visible tail, agile forward-leaning stance.
- Keep the staff and tail inside the canvas. No ground plane, cast shadow, scenery, labels, UI, frame, watermark, or extra character.
- Preserve the exact 128×192 output canvas ratio/dimensions after high-resolution generation and nearest-neighbor reduction.

### 2026-11-13 — Tang Sanzang
- One isolated, complete, calm 3/4 full-body pilgrim sprite; transparent background.
- Monk first, not a wizard: monk headwear/clean shaved head as appropriate to the chosen canonical design, layered saffron/ochre kasaya, travel robe, scripture scroll or monk's staff as a restrained secondary prop.
- Gentle, morally steady posture; slim silhouette clearly distinct from Wukong, Bajie, and Wujing.
- Exact 128×192 output.

### 2026-11-14 — Zhu Bajie
- One isolated, complete, heavy-set 3/4 full-body sprite; transparent background.
- Strong pig-head silhouette, snout/tusks/ears, rounded but powerful body, dark earth-tone travel clothing, unmistakable nine-toothed rake.
- Give him warmth and comic personality without making him childish or a mascot. Keep rake head and ears inside the canvas.
- Exact 128×192 output.

### 2026-11-15 — Sha Wujing
- One isolated, complete, tall/broad 3/4 full-body sprite; transparent background.
- Stable sand/water-blue-grey palette, rugged travel gear or restrained armor, recognizable beard/hair/beads, and a crescent-moon spade / monk's spade.
- Quiet, dependable, grounded silhouette; must not read as a second Bajie.
- Exact 128×192 output.

### 2026-11-16 — Bai Longma
- One isolated, complete, horizontal quadruped dragon-horse sprite; transparent background.
- White horse body with unmistakable Eastern dragon ancestry: subtle horns, scaled details, flowing mane, expressive dragon-like face and tail. It must not look like an ordinary stable horse.
- Use a clear 3/4 side view and preserve all four legs, hooves, mane, and tail.
- Exact 160×128 output. Do not force Longma into a humanoid frame.

### 2026-11-17 — Yellow Wind King
- One isolated, complete, imposing boss sprite; transparent background.
- Yellow/ochre/brown wind-demon identity with a readable weasel/marten-like demon face, strong boss silhouette, layered robes/armor, and a controlled sand/wind motif.
- Must read larger and more threatening than a common enemy when displayed in battle. Avoid making him look like a human soldier or a generic wolf.
- Exact 144×192 output canvas; if a larger boss presentation is needed, change its presentation scale in code deliberately rather than silently changing the texture canvas.

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

## 5. Hard technical contract — preserve character canvas sizes

The current `ui/visual_overlay.gd` draws character textures using their raw width and height multiplied by a per-character presentation scale. Changing source texture dimensions changes the on-screen size even if the art itself looks identical.

Therefore the final character PNG/WebP canvas must exactly match the current SVG fallback dimensions:

| Character | Canvas |
|---|---:|
| Wukong | 128×192 |
| Tang | 128×192 |
| Bajie | 128×192 |
| Wujing | 128×192 |
| Longma | 160×128 |
| Yellow Wind King | 144×192 |

Generate at the highest useful resolution available, then trim transparent excess without cutting any silhouette and place/scale the sprite into the exact canvas. Use nearest-neighbor pixel resizing only; do not introduce blur/anti-aliasing. Keep transparent padding consistent and keep the feet/hooves and weapons inside the canvas.

The exact-size contract is also enforced by `combat/test_visual_asset_contract.gd`. If a deliberate future change requires different dimensions, update `VisualOverlay`, all dependent layouts, and the regression in the same reviewed change.

## 6. Daily post-generation checklist

For each generated asset, the Agent must:

1. Inspect the image visually at native size and at the in-game intended scale.
2. Confirm transparent alpha for character sprites; no checkerboard painted into the image.
3. Check anatomy, silhouette, character-defining props, clean pixel clusters, and no missing/cropped extremities.
4. Crop/trim only as needed; preserve the exact canvas contract above.
5. Save the production file to the exact path in the queue. Do not replace or rename the SVG placeholders.
6. Add a dated development log with the prompt summary, output dimensions, processing steps, file SHA/path, and acceptance/rejection result.
7. Run exact-head Godot Runtime CI. Inspect the log for `PASS res://combat/test_visual_asset_contract.gd` and the full `RUNTIME_SUITE_PASS` result. Do not claim success from a queued/in-progress run.
8. Update this schedule, `docs/AI_MEMORY.md`, `AI_HANDOFF.md`, and the development-log index.
9. After the character/background batch is complete, run Web Demo build/deploy and inspect actual game screenshots. Resource-load CI alone is not aesthetic acceptance.
10. Once today's image task is done, continue with non-generation work. Do not spend another generation call for the same local date.

## 7. Non-generation work to do between scheduled images

Until the next calendar day, continue useful work without another image-generation call:
- Verify output dimensions/alpha and refine the crop using local image processing.
- Check catalog paths and pixel filtering; preserve nearest-neighbor rendering.
- Improve screenshot capture/review and the visual acceptance checklist.
- Audit current SVG fallbacks and scenes without reworking game logic.
- Update source docs and handoff records; run Runtime/Web CI when there is a meaningful change.
- Keep the six SVG fallbacks and all game logic intact until final assets pass review.

## 8. Authority and status

- This schedule is the canonical daily queue. Generated schedule graphics are inspiration only and never override this Markdown.
- A planned asset is not complete until the file exists at the specified path and passes the required review/CI gates.
- The 2026-11-11 planning-poster generation is explicitly not accepted as a production asset. First production asset remains Wukong on 2026-11-12.
