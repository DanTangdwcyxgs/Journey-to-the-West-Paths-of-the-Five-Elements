# Visual Art Review Standard

> Mandatory acceptance contract for every AI-generated or externally supplied character, creature, prop, VFX, UI illustration, and environment asset in Journey to the West: Five Elements Road. Technical validity alone is never aesthetic acceptance.

## 1. Non-negotiable rejection gates

Any single failure means **REJECTED**, regardless of score:
1. **Project identity:** Must match the approved Chinese-mythology JRPG vision, canonical character/place/prop identity, and narrative docs. No generic fantasy substitution or lore-breaking redesign.
2. **Correct medium:** Character sprites require deliberate pixel art: crisp pixel clusters, stepped contours, readable color blocks, controlled highlights/shadows, and consistent pixel scale. Soft painterly rendering, airbrush gradients, vector-smooth edges, photorealism, glossy 3D, and accidental anti-aliasing are not substitutes.
3. **Recognizable silhouette:** The subject reads immediately at actual game scale. Required anatomy, costume landmarks, signature props, and distinguishing traits must be visible and unobscured.
4. **Anatomy / spatial integrity:** No missing or extra limbs, malformed joints, duplicated features, broken perspective, clipped extremities, intersecting props, or impossible equipment placement.
5. **Consistency:** Multi-view sheets depict the same model, proportions, costume, palette, equipment, pose, and grip. Only viewing direction changes unless the brief explicitly says otherwise.
6. **Canvas / transparency:** Exact dimensions and aspect ratio follow the schedule/catalog. Character sheets require genuine alpha; a painted checkerboard fails. Scene art follows the specified 16:9 contract.
7. **Clean delivery:** No watermark, signature, captions, labels, text, UI, frame, border, accidental background, compression artifacts, or unrelated elements unless explicitly requested.
8. **Integration readiness:** Approved crops preserve proportions and complete silhouettes, use nearest-neighbor processing only, and pass catalog/runtime contracts. CI proves loading and dimensions, not art quality.

## 2. Separate review stages

- **A — Prompt compliance:** Subject, approved design, view/layout, pose, props, exclusions, and output format.
- **B — Native-resolution inspection:** Inspect untouched source at 100% and enlarged nearest-neighbor scale. Check clusters, edges, anatomy, transparency, repeated views, and canvas boundaries.
- **C — Gameplay-scale inspection:** View the intended crop at native game size and actual UI presentation scale. Required identity features must remain legible.
- **D — Integration verification:** Run preparation tooling, inspect source archive and output crop, verify path/dimensions/alpha, and run exact-head Art Tooling + Godot Runtime CI.
- **E — Player-facing review:** Inspect actual Main Menu, Journey, battle, and WorldMap screenshots as applicable. CI and a clean crop do not prove visual quality.

Record each stage separately; never collapse them into a single “looks good” decision.

## 3. Scoring rubric (100 points)

| Category | Points | Evidence |
|---|---:|---|
| Pixel craft / art direction | 25 | Crisp intentional clusters, coherent pixel scale, stepped contours, controlled palette and shading |
| Identity / silhouette | 20 | Instantly recognizable; canonical features and signature props visible |
| Anatomy / pose / equipment | 15 | Believable anatomy, stable stance, correct grip, no clipping/intersections |
| Multi-view consistency / composition | 15 | Same model, correct order, scale, baseline, spacing, complete silhouettes |
| Palette / material readability | 10 | Controlled colors, distinct materials, no muddy/noisy clusters |
| Canvas / transparency / delivery | 10 | Exact ratio/dimensions, genuine alpha where required, clean file/path |
| Gameplay-scale readability | 5 | Clear at actual game display size and compatible with UI/background |

**Pass: at least 90/100 and every critical gate passed.** A high score never overrides a critical failure. Record category scores and evidence; do not inflate scores.

## 4. Character turnaround checklist

- Exact scheduled 2×2 quadrant order; four full-body orientations, isolated in their own quadrants.
- Same model, face, anatomy, costume, palette, accessories, weapon, pose, grip, scale, camera, and ground baseline.
- Required identity traits and signature equipment visible in every view where physically possible.
- Tail, mane, ears, headwear, weapon tips, hooves, feet, robe hems, and extremities not hidden, cropped, or fused into the silhouette.
- Genuine transparent alpha in empty regions; no checkerboard, shadow plane, scenery, or painted backdrop.
- No extra character, alternate costume, extra weapon, text, watermark, panel frame, or UI.
- Inspect source and top-left canonical crop separately; do not squeeze all four views into one runtime sprite.

**Wukong-specific gates:** unmistakably simian face/muzzle and ears; golden brow fillet; red/vermilion/ochre clothing; long visible monkey tail; recognizable Ruyi Jingu Bang held upright beside the body in the same anatomical right hand and grip across all views. Tail and staff must not overlap or merge; he must not read as a human general.

## 5. Environment / scene checklist

- Composition supports gameplay camera and leaves deliberate space for party, enemies, UI, markers, or route overlays.
- Foreground, mid-ground, and background separate clearly; landmarks support the approved Chinese-mythology setting.
- Lighting and palette match restrained HD-2D mood; detail density does not obscure gameplay silhouettes or interaction points.
- No baked-in text/UI/health bars/map pins/labels where the game renders these dynamically.
- No perspective contradictions, garbled/repeated architecture, focal clutter, or visual noise.
- Exact 16:9 output and correct catalog filename/path.

## 6. Decision states and evidence

Use only:
- **REJECTED** — any critical gate fails or score <90; do not archive as approved source, crop, catalog, or ship.
- **ACCEPTED FOR INTEGRATION** — all critical gates pass and score ≥90; may proceed to integration, not yet production-ready.
- **INTEGRATED — AWAITING SCREENSHOT REVIEW** — integration and exact-head CI pass, but player-facing review remains.
- **PRODUCTION ACCEPTED** — all gates, exact-head CI, gameplay-scale review, and relevant screenshots pass.

Each record includes asset/date, source dimensions/format, alpha/ratio checks, category scores, critical failures, decision, file hashes/paths if accepted, exact tested commit SHA, CI run IDs, and screenshot evidence or explicit no-screenshot statement. Never call an asset final/production-ready/complete unless its state is **PRODUCTION ACCEPTED**. Rejected outputs never enter production directories.
