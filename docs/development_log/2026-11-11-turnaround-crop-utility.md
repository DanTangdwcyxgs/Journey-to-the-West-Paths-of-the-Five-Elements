# 2026-11-11 · Four-View Turnaround Crop Utility

## Goal

Prepare a deterministic, reviewable path from a generated 2×2 turnaround sheet to the exact-size runtime character texture without spending another image-generation call.

## Implementation

Added `tools/art/prepare_character_turnaround.py`.

The utility:
- Accepts the six known character IDs and their exact runtime canvas sizes.
- Requires a PNG with an actual alpha channel and an even 2×2 sheet. It validates all four quadrants in layout order: each must be non-empty, have at least 5% fully transparent pixels, and have a visible bounding box that does not touch the quadrant edge.
- Copies the original source PNG byte-for-byte into `assets/art/source_sheets/characters/<id>_turnaround.png`.
- Crops only the top-left primary front three-quarter view.
- Fits the view proportionally inside the exact runtime canvas, uses nearest-neighbor resizing, applies 4 px transparent padding, and bottom-aligns the feet/hooves.
- Writes the gameplay crop to `assets/art/characters/final/<id>.png`.
- Refuses to overwrite either output unless `--overwrite` is explicitly passed.
- Prints JSON metadata including quadrant bounds, resulting dimensions, and source SHA-256.

The helper does not decide whether the other three quadrants show the same character, consistent costume, identical pose, or correct view direction. Those remain mandatory human review checks. It also does not claim aesthetic approval.

## Tests and CI

Added `tools/art/test_prepare_character_turnaround.py` with 12 unit tests covering:
1. Byte-identical source archive and top-left-only extraction.
2. Aspect-ratio preservation and bottom alignment.
3. Real alpha-channel requirement.
4. Rejection of an opaque/flattened top-left panel.
5. Even 2×2 source dimension requirement.
6. Unknown character ID rejection.
7. Overwrite protection.
8. Longma's horizontal 160×128 output.
9. Edge-touching/cropped-view rejection.
10. Empty top-left quadrant rejection.
11. Empty non-primary rear-three-quarter quadrant rejection.
12. Non-primary side-profile edge-crop rejection.

Added `tools/art/requirements.txt` and `.github/workflows/art-tooling.yml` so the helper tests run independently of the Godot Runtime workflow when art tooling files change.

The new test cases explicitly prove that missing or edge-cropped secondary views reject the entire sheet. The suite now contains 12 tests; exact-head CI is pending.

## Documentation

- `tools/art/README.md`: installation, command, output contract, limitations, and tests.
- Updated `AI_ART_PRODUCTION_SCHEDULE.md`, `AI_ASSET_DELIVERY_SPEC.md`, `AI_ASSET_PIPELINE.md`, visual README, prior turnaround strategy log, development-log index, `docs/AI_MEMORY.md`, and `AI_HANDOFF.md`.

## Current status / limitations

- No new image was generated. The 2026-11-11 image-generation quota remains consumed by the rejected planning poster.
- No game character art was generated or accepted.
- The tool assumes the top-left quadrant of the reviewed 2×2 source sheet is the primary front three-quarter view. It cannot automatically validate all other views' identity or artistic consistency.
- Historical PASS: helper/code head `69fc03a38b02221e57b66003c1dbb1440c51a307`, Art Tooling [42947150489](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42947150489), the original 10-test suite passed. The two secondary-quadrant guards were added after this run; see the latest validation below.
- PASS: same exact head, Godot Runtime [42947150307](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42947150307), log confirms `PASS res://combat/test_visual_asset_contract.gd` and `RUNTIME_SUITE_PASS tests=52`.
- These runs verify the helper and runtime state at the cited SHA. If later documentation commits move the branch, inspect the newest head's Actions before reporting it green.
- Existing Godot Runtime remains a separate validation gate for the final output dimensions and catalog loading.

## Next Agent

On 2026-11-12, generate exactly one Wukong four-view sheet. Review all quadrants manually, then run:

```bash
python tools/art/prepare_character_turnaround.py --input /absolute/path/wukong_turnaround.png --character wukong
```

Inspect both archived source and output crop, verify the visual contract and exact dimensions, then continue the normal development log, AI memory, handoff, and Runtime workflow. Do not retry generation on the same local date.
