# 2026-11-11 · Wukong Turnaround Pose Brief Alignment

## Finding

A consistency audit found three different levels of pose wording for the first character-generation slot:
- The dedicated Wukong prompt specified an upright, neutral battle-ready standing pose, with the staff upright beside the body.
- The daily schedule described the figure as slightly forward-leaning with an action-ready staff pose.
- The legacy visual pipeline summarized Wukong's posture as attack-oriented.

These descriptions could cause an image-generation agent to produce different actions or weapon placements across the four views.

## Decision

The dedicated prompt at `docs/visual_reference/prompts/2026-11-12-wukong-turnaround.md` is the detailed canonical pose reference. The shared brief now matches it:
- Feet about shoulder-width apart, knees slightly relaxed, torso upright with subtle agile readiness.
- Keep the exact same pose, limb placement, and weapon grip across all four orientations.
- Hold the Ruyi Jingu Bang upright beside the body at a slight natural angle in Wukong's anatomical right hand.
- Rotate the same model only; do not swing, thrust, or change into four separate action poses.

## Files synchronized

- `docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md`
- `docs/visual_reference/AI_ASSET_PIPELINE.md`
- `docs/visual_reference/AI_ASSET_DELIVERY_SPEC.md`

The dedicated prompt remains unchanged. No image generation was performed as part of this documentation audit, and the 2026-11-11 daily generation allowance remains consumed.

## Validation

This is a documentation-only alignment. The final branch head must be checked against its own Art Tooling and Godot Runtime workflow runs before reporting CI status. No generated art, gameplay behavior, asset catalog, or runtime contract was changed.

## Next step

On 2026-11-12, use the dedicated Wukong prompt exactly once. Inspect all four views manually before running the turnaround crop utility; do not retry generation that day if the result is rejected.
