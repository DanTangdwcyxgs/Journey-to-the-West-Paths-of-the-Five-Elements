# VisualOverlay Unsupported Scene Fallback — 2026-11-11

## Finding

A review of the always-on VisualBackdrop autoload found that VisualOverlay._draw() used Journey as its unconditional fallback. Any active scene not explicitly handled by the menu, battle, world map, or Yellow Wind branches therefore received the Journey party stage.

The current UI scene catalog includes six screens that are not character-stage scenes: bounty preparation, camp, party, preparation, region exploration, and shop. These screens could unintentionally show the Journey character lineup on top of their own UI.

## Change

- Added one explicit stage_kind_for_scene(scene_path) resolver for the six supported stage families: main menu, Journey, battle, world map, Yellow Wind ridge, and Yellow Wind cave.
- Reused the resolver for both scene background selection and foreground stage drawing so those routes cannot silently diverge.
- Removed the unconditional Journey fallback. Unknown and non-stage scenes now receive no extra character-stage drawing or art background from this overlay.
- Extended combat/test_visual_overlay_layout_contract.gd with a 12-scene route table: six supported screens map to their intended stage and the six non-stage screens map to an empty stage.

## Scope

No combat, narrative, save, route progression, or asset-generation behavior changed. No image generation was used. This is a presentation-routing correction only.

## Validation

- PASS: implementation and regression head 8866bcf06ad5933296759e6cb7fff6b717bb2530: Art Tooling [42966697704](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42966697704) completed successfully with 12 tests / OK; Godot Runtime [42966697762](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/42966697762) completed successfully, including PASS for test_visual_overlay_layout_contract.gd and RUNTIME_SUITE_PASS tests=53.
- No player-facing screenshots were captured or accepted in this pass; final production art is still pending.

## Next

Keep the stage mapping list synchronized when new UI scenes are added. Any new screen should explicitly choose a stage family only if it is intended to display that character/background composition.
