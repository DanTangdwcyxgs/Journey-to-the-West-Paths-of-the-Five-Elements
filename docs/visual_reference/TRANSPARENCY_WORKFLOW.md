# Transparency and Background-Removal Workflow

> Mandatory production procedure for every character, creature, prop, VFX, and other asset whose delivery contract requires transparent pixels. Read this before every image-generation call. The character turnaround crop tool is the final gate, not a background-removal tool.

## 1. Preferred method: generate real transparency at the source

1. Use the image-generation tool's explicit transparent-background option when it is available. In ChatGPT ImageGen this means setting `transparent_background=true` in the tool call; do not rely on prompt wording alone.
2. The prompt must also say: "Output a PNG with a genuine RGBA alpha channel. Every empty/background pixel must have alpha 0. Do not draw a checkerboard, white canvas, colored matte, floor, cast shadow, glow, or backdrop. Transparency must be encoded in the file, not illustrated."
3. Request one clean subject / one 2×2 turnaround sheet as specified by the asset brief. Keep the background empty and all views separated by transparent gutters.
4. Do not assume the option worked. Inspect the actual saved file before any archive, crop, catalog, or commit operation.

### Mandatory file inspection

Use Pillow or an equivalent image inspector:

```bash
python - <<'PY'
from PIL import Image
from pathlib import Path
p = Path("/absolute/path/generated.png")
im = Image.open(p)
print("format:", im.format, "mode:", im.mode, "size:", im.size)
print("bands:", im.getbands())
print("transparency metadata:", im.info.get("transparency"))
if "A" not in im.getbands() and "transparency" not in im.info:
    raise SystemExit("REJECTED: no real alpha channel")
rgba = im.convert("RGBA")
alpha = rgba.getchannel("A")
print("alpha extrema:", alpha.getextrema())
print("fully transparent pixels:", alpha.histogram()[0])
print("partially transparent pixels:", sum(alpha.histogram()[1:255]))
print("fully opaque pixels:", alpha.histogram()[255])
if alpha.histogram()[0] == 0:
    raise SystemExit("REJECTED: alpha channel exists but contains no transparent pixels")
PY
```

- A PNG mode of `RGB` is not transparent.
- `RGBA` alone is not enough: verify that the alpha channel actually contains transparent pixels in the empty background/gutters.
- A checkerboard visible in the pixels is a painted background, not transparency.
- Do not convert an RGB image to RGBA and call it transparent; that only adds an all-opaque alpha channel.
- Inspect corners, all four gutters, edges around hair/fur/tails/weapons, and the full subject at 100%. Confirm the transparency grid shown by the image viewer is a viewer overlay, not part of the image.

## 2. Fallback when native transparency is unavailable or fails

Do not spend another generation call. A same-day retry is forbidden. Preserve the raw generated file separately and choose one of these paths:

### A. Flat chroma/key-color background — preferred fallback

Use only when the generated background is a single, perfectly flat, high-contrast color that is absent from the character and its materials. A saturated key color such as pure magenta or cyan may be suitable, but choose it per asset; never assume green is safe. The subject must not contain the selected key color.

- The background must be uniform from corner to corner: no gradient, texture, checkerboard, scenery, ground plane, vignette, cast shadow, glow, or compression noise.
- Ask for a hard, clean silhouette and no colored spill around the subject.
- Use a local chroma-key / flood-fill background-removal tool that removes only the connected background region touching the canvas border. Do not globally delete every pixel of that color; the same color may legitimately appear inside the character.
- Preserve edge pixels carefully. Inspect for key-color halos, holes in the subject, missing hair/fur, tail/weapon loss, and semi-transparent fringe.
- Export a real RGBA PNG. Then run the mandatory alpha inspection in section 1 and the visual review standard.

### B. Pure white background — conditional fallback only

White is not the default fallback. Use it only if the entire subject has no white, cream, pale gray, silver, bright highlights, white hair/fur, or other regions that could merge with the background.

- Require a perfectly uniform pure-white background (#FFFFFF), no shadows, gradients, texture, or checkerboard.
- Remove only the white region connected to the outer canvas using a tolerance-controlled flood-fill / segmentation tool. Never globally make all white pixels transparent.
- Manually inspect every edge at 100% and nearest-neighbor enlargement. White clothing, eyes, teeth, fur, metal highlights, and anti-aliased boundary pixels must remain intact.
- If the tool leaves a white halo or erases pale subject details, reject the image. Do not try to hide the damage with a dark outline or blur.

### C. AI segmentation / manual masking

If the background is not perfectly flat but the subject is clearly separable, a trusted segmentation/background-removal tool may be used as a rescue attempt without another generation call. Treat its output as an untrusted mask:

- Review the mask at 100% and enlarged nearest-neighbor scale.
- Restore missing fine structures manually: hair/fur, ears, fingers, weapon tips, robe hems, hooves, tails, straps, and gaps between limbs/equipment.
- Remove leftover background islands and halos without softening pixel contours.
- Rebuild pixel-art edges as deliberate pixel clusters; do not accept blurry feathered edges.
- Export RGBA PNG and run the same alpha and art checks.

### D. Immediate rejection cases

Reject without further processing if any of these apply:
- Painted checkerboard / transparency grid.
- Complex scenery, textured or gradient background, cast shadow, floor plane, or background touching/covering the subject.
- Key color is present in the subject or the background is not uniform enough for safe keying.
- White background overlaps with white/pale character details and no reliable mask can separate them.
- Segmentation removes or invents anatomy, equipment, fur, hair, tail, or costume detail.
- Edge halos, holes, blur, or color spill remain after one careful cleanup pass.

Do not use repeated destructive edits to rescue a fundamentally unsuitable generation. Mark it `REJECTED`, keep the raw file out of production folders, record the failure, and continue non-generation work.

## 3. Preserve source and produce the canonical sheet

- Keep the untouched generated original in the review/artifact area until the asset is accepted or rejected. Never overwrite the only copy.
- If background removal was needed, save the processed RGBA result as a separate file. Do not pretend it is the untouched original.
- The approved transparent 2×2 sheet must preserve the exact quadrant order and contain at least 5% fully transparent pixels in each quadrant; every quadrant must have safe transparent margins and no edge-touching subject pixels.
- Only after manual review and alpha validation, run the canonical preparation tool:

```bash
python tools/art/prepare_character_turnaround.py --input /absolute/path/approved_rgba_turnaround.png --character <character_id>
```

- The tool must accept the real alpha channel and create the source-sheet archive plus the top-left runtime crop. If it rejects the file, stop; do not bypass its validation or edit its checks merely to force acceptance.
- Inspect the untouched/processed source sheet and the runtime crop separately. The crop must preserve the exact canvas contract and nearest-neighbor pixel edges.
- Do not pass `--overwrite` unless the old source and crop have been reviewed and replacement is explicitly intended.

## 4. Acceptance and recordkeeping

A technically transparent image is not automatically good art. Apply every critical gate and the ≥90/100 score in [ART_REVIEW_STANDARD.md](ART_REVIEW_STANDARD.md). Record separately:

- Original format/mode/dimensions and whether native alpha was present.
- Whether background removal was used; method, key color/tolerance or segmentation tool, and any manual mask cleanup.
- Alpha-channel evidence (transparent pixel count / quadrant ratios).
- Pixel-art, silhouette, identity, anatomy, consistency, and gameplay-scale review.
- Decision: `REJECTED`, `ACCEPTED FOR INTEGRATION`, `INTEGRATED — AWAITING SCREENSHOT REVIEW`, or `PRODUCTION ACCEPTED`.
- Raw and processed file hashes/paths, exact tested commit SHA, CI run IDs, and screenshot evidence or explicit absence.

No RGB/checkerboard file may enter `assets/art/source_sheets/characters/` or any production directory. Never mark an image complete based only on a prompt, preview, or successful file conversion.

## 5. Copy-ready transparency instruction

Append this to every prompt for an asset requiring transparency:

> **TRANSPARENCY IS A FILE-LEVEL REQUIREMENT:** deliver a PNG with genuine RGBA transparency. The background and all empty areas must have alpha=0. Do not draw a checkerboard pattern or simulate transparency. Do not add a white/colored canvas, scenery, floor, cast shadow, vignette, glow, or backdrop. Keep clean transparent margins around every silhouette and prop. If your image system cannot create actual transparency, use one perfectly flat, uniform solid key-color background that is not present anywhere in the subject, with no gradients or shadows; never draw a checkerboard. The file will be inspected for a real alpha channel and may be rejected if the background cannot be safely removed.

The prompt instruction is a fallback hint only. When supported, the tool-level transparent-background option must still be enabled.
