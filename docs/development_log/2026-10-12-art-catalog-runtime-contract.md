# 2026-10-12 · Runtime Art Catalog Contract

## Goal
Make the existing visual asset regression follow the same resolved paths as production so final PNG/WebP delivery is exercised automatically without replacing placeholders or claiming visual acceptance.

## Changes
- Updated `combat/test_visual_asset_contract.gd` to resolve all six character textures through `ArtAssetCatalog`, verify loadability and dimensions, and assert the catalog's PNG → WebP → SVG priority against files actually present.
- Scene textures now resolve through `ArtAssetCatalog` as well; existing Journey and Yellow Wind battle environment-layer source markers remain checked.
- Kept final-art files optional: absent PNG/WebP assets correctly fall back to the current SVG placeholders. This lets the same test cover today's repository and future art drops without renaming or promoting placeholders.
- No generated infographic/status image was added to game assets: it is not a character sprite and would violate the asset delivery gate.

## Validation
- Source changes and documentation synchronization only in this step; no local Godot executable was available through the GitHub connector, so no local runtime claim is made.
- Exact-head GitHub Actions must be checked after this commit. The prior Runtime PASS does not automatically validate the new test.

## Known limits
- Loadability and path-priority tests do not judge anatomy, silhouette readability, alpha-edge quality, pixel density, or in-game composition.
- Six individual transparent character assets remain pending image generation and visual review.

## Next step
When generation is available, add the six separate files under `assets/art/characters/final/`, inspect actual Journey and battle compositions, then run exact-head Godot Runtime and Web Demo build/deploy checks.
