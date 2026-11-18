# Character Turnaround Preparation

This tool prepares the current runtime sprite from a reviewed 2×2 character turnaround sheet. Before running it, follow [TRANSPARENCY_WORKFLOW.md](../../docs/visual_reference/TRANSPARENCY_WORKFLOW.md) to generate or safely recover a genuine alpha channel.

## Install

```bash
python -m pip install -r tools/art/requirements.txt
```

## Run

From the repository root, after visually reviewing the generated sheet:

```bash
python tools/art/prepare_character_turnaround.py --input /absolute/path/wukong_turnaround.png --character wukong
```

Supported character IDs: `wukong`, `tang`, `bajie`, `wujing`, `longma`, `yellow_wind`.

The command writes two files:

- The original PNG, byte-for-byte, to `assets/art/source_sheets/characters/<id>_turnaround.png`.
- The top-left primary front three-quarter view to `assets/art/characters/final/<id>.png`.

The script does not edit or delete the input. It refuses to overwrite either destination unless `--overwrite` is explicitly supplied.

## Expected 2×2 layout

- Top-left: primary front three-quarter view (the only view extracted for today's runtime sprite).
- Top-right: right-facing side profile.
- Bottom-right: rear three-quarter view.
- Bottom-left: left-facing side profile.

## Processing and safety rules

- Source must be a PNG with a real alpha channel and actual transparent pixels. Flattened backgrounds and painted checkerboards are rejected. This script does not remove backgrounds or convert RGB into transparency; use the documented background-removal workflow first.
- The source width and height must both be even so the 2×2 quadrants can be split exactly.
- Every quadrant must contain visible artwork, at least 5% fully transparent pixels, and no visible pixels touching its outer edge. This catches obviously missing, flattened, or edge-cropped directions before the source is archived.
- The source sheet is archived unchanged. Only the top-left quadrant is cropped using its alpha bounds.
- The crop is proportionally fitted inside the current character canvas with 4 px transparent padding, bottom-aligned feet/hooves, and nearest-neighbor resizing. The character is never stretched to fill the canvas.
- Exact runtime canvases: Wukong/Tang/Bajie/Wujing 128×192; Longma 160×128; Yellow Wind King 144×192.
- The script cannot determine whether all four quadrants depict the same character, costume, stance, or weapon grip. A human must inspect the complete source sheet before accepting the asset.
- If validation fails, stop and record the asset as rejected. Do not bypass alpha checks or regenerate on the same day. See the transparency workflow for the only permitted rescue methods. Do not make another image-generation call that day.

## Tests

```bash
python -m unittest discover -s tools/art -p 'test_*.py' -v
```

The 12 tests cover source preservation, isolation of the primary view, presence/edge-safety of all four quadrants, target dimensions, aspect-ratio preservation, bottom alignment, real transparency, invalid sheets, and overwrite protection.
