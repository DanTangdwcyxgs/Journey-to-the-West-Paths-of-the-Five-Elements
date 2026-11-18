# 2026-11-18 — Transparent Asset Generation and Background-Removal SOP

## Goal
Prevent repeated rejection of character sheets caused by fake/flattened transparency. Define how future agents request true transparency, inspect the delivered file, recover safe flat backgrounds without spending another generation call, and reject unsafe outputs.

## Repository audit
- Existing tools/art/prepare_character_turnaround.py requires a real alpha channel, transparent margins in every quadrant, and safe non-edge-touching silhouettes.
- The crop utility does not remove backgrounds; it must not be bypassed or weakened.
- The 2026-11-18 Yellow Wind King result was RGB with a checkerboard painted into the pixels. It cannot be made transparent by merely converting RGB to RGBA.
- A previous run delivered native RGBA transparency, so future calls must explicitly enable the image tool's native transparent-background option instead of relying only on prompt wording.

## What changed
- Added canonical docs/visual_reference/TRANSPARENCY_WORKFLOW.md.
- Native transparency is preferred; explicitly enable transparent_background=true in ImageGen when supported.
- Inspect PNG format, mode, bands, alpha histogram, and actual transparent pixels before any archive/crop.
- Distinguish real transparency from painted checkerboards and all-opaque RGBA.
- Safe no-retry fallback: flat high-contrast key color absent from the subject, connected-background flood-fill/chroma-key; white is conditional only when the subject has no white/pale details; segmentation/manual masking only with close manual review.
- Reject checkerboards, complex backgrounds, unsafe key colors, lost subject details, halos, holes, and blurred pixel edges.
- Preserve raw output; process to a separate RGBA file; then use the existing crop tool.
- Updated ART_REVIEW_STANDARD.md, AI_ART_PRODUCTION_SCHEDULE.md, Wukong prompt, AI_ASSET_PIPELINE.md, AI_ASSET_DELIVERY_SPEC.md, tools/art/README.md, AI memory, handoff, and index.

## Operational decision tree
1. Generate with native transparent-background mode enabled.
2. Inspect the actual file. Require a PNG with a real alpha channel and alpha=0 in empty background/gutters.
3. If RGB/no alpha, preserve raw file and do not retry that day.
4. If background is a perfectly uniform, subject-safe flat color, attempt connected-background removal; never globally delete that color.
5. White is allowed only if no white/cream/pale gray/silver subject detail can be lost. Otherwise choose a different absent key color or use a reviewed segmentation mask.
6. If background is checkerboard, complex, touching the subject, or removal damages details/edges, reject.
7. Export separate RGBA PNG, inspect alpha and all edges at 100%, then manually review the art.
8. Only then run the unchanged canonical turnaround crop tool. Never weaken its alpha checks.

## Validation / limitations
- Documentation-only change. No new image was generated; the 2026-11-18 daily generation budget was already consumed.
- No code, crop utility, tests, production assets, catalog, game runtime, or screenshot evidence changed.
- Exact-head Art Tooling and Godot Runtime CI must be checked for the final documentation commit before reporting validation.
- This SOP describes permitted rescue methods; it does not claim a background-removal tool has been installed or executed. If a future agent lacks a safe segmentation/keying tool, leave the image rejected rather than improvise.

## Next step
On the next scheduled image date, read the schedule, this SOP, the asset prompt, and the art review standard. Enable native transparency in the image tool call, inspect the actual alpha channel immediately, and use no more than the day's one call. If the result is opaque, follow the decision tree above and do not regenerate.