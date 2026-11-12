# 2026-11-12 — Full-Project AI Art Prompt Library Baseline

## Goal
Expand art preparation from a single-character prompt into a project-wide asset prompt system covering characters, monsters, bosses, locations, equipment, consumables, VFX and UI.

## What changed
- Added `docs/visual_reference/prompts/MASTER_ASSET_PROMPT_LIBRARY.md` with a global style contract, individual ready briefs for all five playable protagonists and Yellow Wind King, per-ID briefs for the currently declared enemy roster, named scene briefs for current world/story locations, item/prop briefs, VFX families and UI asset families.
- Added explicit design-input holds where repository canon or runtime dimensions are not sufficient to safely invent a design (notably optional bounty boss anatomy, UI atlas dimensions and future NPC inventory).
- Established a strict status ledger: generation is not completion; only PRODUCTION ACCEPTED closes an asset. Rejections remain in history and are rescheduled, never retried on the same local date.
- Added an inventory completeness rule requiring future audits against narrative, combat, world, item, scene and runtime-loaded resource data.

## Why
A daily generator should execute a prepared queue rather than invent art direction at generation time. The prompt must describe identity, silhouette, camera, composition, palette, exact output type, negative constraints and review gates for every individual asset.

## Systems affected
Documentation and art-production workflow only. No game code, gameplay data, production assets, SVG fallbacks, runtime catalog or scenes changed.

## Files
- `docs/visual_reference/prompts/MASTER_ASSET_PROMPT_LIBRARY.md`
- `docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md`
- `docs/visual_reference/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-11-12-full-project-art-prompt-library.md`

## Tests
Documentation-only. No image generation was performed. No local tests or runtime build were run.

## Godot Runtime status
Not run for this documentation-only change. Exact-head Actions must be checked after commit; prior SHA results do not transfer.

## Known issues
The prompt library is a comprehensive baseline for currently identified content, not a false claim of exhaustive coverage of future content. The next inventory pass must enumerate every NPC/event character, every reward/material and every runtime-loaded visual slot. Some bosses require explicit design approval before generation. UI icon/frame pixel dimensions and VFX animation import contracts must be read from actual runtime assets before those prompts are released.

## Next step
Use the Wukong prompt once on its scheduled 2026-11-13 America/Los_Angeles date. Continue non-generation inventory work to expand NPC/prop/VFX/UI IDs. After each accepted asset, record source/runtime paths, dimensions, hash, exact-head CI and screenshot evidence, then advance the queue.

## Handoff point
The daily schedule remains the execution cursor. The master library is the source for per-asset art direction. Never skip the review standard or call a generated/rejected sheet complete.
