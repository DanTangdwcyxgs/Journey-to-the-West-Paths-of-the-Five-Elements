# 2026-11-13 — Sun Wukong Four-View Turnaround Generation

> Mandatory review standard: [ART_REVIEW_STANDARD.md](../ART_REVIEW_STANDARD.md). This is the copy-ready brief for the Wukong image-generation slot. Check `AI_ART_PRODUCTION_SCHEDULE.md` first. The owner has one image-generation call per local calendar day; use exactly one call for this sheet and do not retry it that day.

## Deliverable

One transparent PNG containing a single-character 2×2 turnaround sheet. It is a character model reference, not a poster, game screenshot, UI mockup, multi-character contact sheet, or animation sprite sheet.

All four quadrants must depict the exact same Sun Wukong design at the same scale and in the same standing, battle-ready pose. Rotate the same model around its vertical axis; do not invent four different actions or change the costume, weapon grip, proportions, or silhouette between views.

## Copy-ready generation prompt

Create a polished, production-quality **2D pixel-art character turnaround sheet** for Sun Wukong, the Monkey King, for a serious Chinese-mythology HD-2D turn-based JRPG.

The image must be a clean **2×2 grid of four full-body views of ONE identical character**, with the same anatomy, costume, colors, ornaments, proportions, standing pose, limb positions, and weapon grip in all four quadrants. Only rotate the character's viewing direction. The four views must be equally large and share the exact same ground baseline and camera scale.

**Quadrant order, clockwise:**
1. **Top-left — canonical front three-quarter view:** Wukong faces slightly toward the viewer, with his simian face clearly readable. This is the main view that will be cropped for the current game.
2. **Top-right — right-facing side profile:** a true side view, nose and chest facing image-right.
3. **Bottom-right — rear three-quarter view:** show the back of the same head, armor, clothing, belt, tail attachment, and carried equipment.
4. **Bottom-left — left-facing side profile:** a true side view, nose and chest facing image-left.

**Character identity and design:**
- Clearly recognizable agile adult monkey king, unmistakably simian rather than a human general: expressive monkey muzzle, short fur texture around the face, alert eyes, distinct ears, and a confident, focused expression.
- A simple, unmistakable golden fillet/headband across the brow. Keep its shape and placement identical in all views.
- Layered red, vermilion, and dark-ochre battle/travel clothing with restrained antique-gold trim, dark leather wraps, practical armor plates, and a coherent back design. Rich but controlled palette; avoid excessive tiny ornaments that disappear at game scale.
- Lean, athletic, compact fighter silhouette. Not bulky, not childlike, not a mascot, and not an oversized boss.
- The Ruyi Jingu Bang is a clearly recognizable golden staff with darker/red end details. Wukong holds it in the same anatomical right hand with the exact same grip and relative position in all four views. Keep the complete staff visible in every quadrant.
- A long, unmistakable monkey tail grows naturally from the lower back and remains visible in all four views. Its curve rotates naturally with the body; do not remove it, hide it behind the legs, or let it merge into the staff.
- Use practical boots/footwear and readable hands. Both feet must be fully visible.

**Pose and composition:**
- Neutral battle-ready standing pose: feet planted about shoulder-width apart, knees slightly relaxed, torso upright with a subtle agile readiness, head level.
- Keep the anatomical left hand relaxed but ready; do not change its position between views.
- The staff is held upright beside the body with a slight natural angle, not swung, thrust, or raised into a different action pose.
- Each figure fills most of its own quadrant height while leaving clear transparent safety margins around the headband, ears, staff tips, tail, hands, and feet.
- Keep all four figures completely inside their own quadrants. No overlap, no crossing into neighboring quadrants, and no cropped extremities or props.
- Use a consistent orthographic/model-turnaround camera with minimal perspective distortion. Do not change scale, zoom, lens, or floor baseline across views.
- Leave a clear transparent gutter between the four views. The quadrant layout is conveyed by the positions only: **do not draw dividers, panel borders, frames, labels, arrows, letters, numbers, captions, or a title.**

**Art direction:**
- Premium hand-crafted pixel-art JRPG sprite-design quality: crisp pixel clusters, deliberate pixel edges, readable color blocking, controlled highlights and shadows, strong silhouette, detailed but not noisy.
- Consistent pixel scale and rendering technique across the entire sheet. No smooth vector outlines, no painterly brush texture, no photorealism, no glossy 3D render, no anime airbrush gradients, and no anti-aliased soft edges.
- The look should feel at home beside a restrained HD-2D Chinese-fantasy environment: traditional Chinese mythological design language, grounded materials, elegant proportions, and warm red/ochre/gold accents.

**Background and exclusions:**
- Real transparent alpha background across the entire image, including all empty space between the figures. Do not simulate transparency with a checkerboard.
- No scenery, architecture, ground plane, cast shadow, smoke, wind effects, particles, decorative backdrop, or environmental lighting.
- No UI, HUD, menus, health bars, icons, logos, signatures, watermarks, written Chinese characters, or any text.
- No extra characters, duplicate heads, extra limbs, alternate costumes, extra weapons, floating props, or decorative silhouettes.

Output exactly one image: the complete four-view turnaround sheet. Prioritize identical character design and pose across all four views, complete silhouettes, clear directional anatomy, and a transparent background.

## After generation — do not generate again

Apply the full review standard. Any failure of pixel-art craft, simian identity, visible tail, upright beside-body staff, same pose/grip, complete silhouettes, genuine alpha, or canvas integrity is an automatic rejection regardless of score. A passing crop tool or CI run does not waive human art review.

1. Inspect all four quadrants manually at full resolution. Reject if the face/costume/weapon/tail changes between views, if any view is missing, if a prop crosses a quadrant boundary, or if the image is flattened.
2. Confirm the exact quadrant order in the prompt. Do not reorder the sheet to make the crop script accept it.
3. Preserve the original image unchanged and run:

   ```bash
   python tools/art/prepare_character_turnaround.py --input /absolute/path/wukong_turnaround.png --character wukong
   ```

4. Inspect the archived source and the 128×192 crop. Confirm the complete staff, tail, headband, and both feet remain visible at native and in-game scale.
5. Do not pass `--overwrite` unless replacement is intentional and the previous files have been reviewed.
6. Update the production schedule, development log, AI memory, and handoff. Run exact-head Art Tooling and Godot Runtime CI.
7. Do not make a second image-generation call on 2026-11-13, even if the result is rejected. Replan the missed asset to the next available date and continue with non-generation work.
