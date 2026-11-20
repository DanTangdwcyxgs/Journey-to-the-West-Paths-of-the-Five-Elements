# 2026-11-20 — First-Battle Tutorial Across the Five Origin Routes

## Goal

Reduce first-combat friction for new players without changing combat balance or the fixed Journey chronology. Every selectable Origin route should explain the shared tactical vocabulary and the selected protagonist's unique combat resource at that route's first authored encounter.

## Starting point

- The 2026-11-19 player-facing vertical-slice audit closed the P0 save / retry / choice-safety issues and identified a P1 gap: there was no first-battle onboarding for target selection, weaknesses and Shield/Break, BP/Boost, items, formation, or character resources.
- The five Origin routes already store their chapter-to-encounter mapping in `data/narrative/origin_chapters.json`. The tutorial should derive the first encounter from that source rather than duplicating chapter IDs in UI code.
- Canonical first encounters in the current route data:
  - Wukong — WUK-02 / WUKONG_ORIGIN_WATER_CAVE
  - Tang — TANG-06 / TANG_ORIGIN_DOUBLE_RIDGE
  - Longma — LONGMA-02 / LONGMA_ORIGIN_SEA_CLIFF
  - Bajie — BAJIE-06 / BAJIE_ORIGIN_GAO_WILD
  - Wujing — WUJING-03 / WUJING_ORIGIN_FLOWING_SANDS

## What changed

- Added `scripts/combat/battle_tutorial.gd` with a data-driven lookup that scans each route's chapter list and returns its first chapter containing an `encounter_id`.
- The tutorial auto-opens only for that route's first Origin battle. Shared Journey battles and optional bounties do not trigger it. A persisted `battle_failed` marker suppresses the auto-popup on the immediate defeat/retry path so the tutorial does not interrupt the retry.
- Added a persistent-in-screen “战斗教学” button so players can reopen the guide at any time during battle.
- The guide explains:
  1. selecting an enemy target and selecting an ally as an item target;
  2. weakness hits, Shield depletion and Break;
  3. BP gain and Boost scaling with skill BP cost;
  4. item use and front/back row damage differences;
  5. the selected protagonist's own resource and associated tactical skill.
- Character tips are specific to the current runtime rules: Wukong's Momentum, Tang's Mercy, Bajie's Rage, Wujing's Tide, and Longma's Dragon Breath.
- Registered `combat/test_battle_tutorial.gd` in the Godot runtime suite. The regression validates all five route lookups, first-battle trigger behavior, no Shared/bounty trigger, character-specific guide availability, and the BattleUI manual entry point.

## Why

The same core combat rules should be explained consistently, while each Origin campaign should still teach the player's chosen protagonist. Deriving the battle trigger from the chapter data keeps onboarding aligned if the route's first encounter is reordered later.

## Systems affected

- Presentation: BattleUI and its AcceptDialog help panel.
- Combat support: read-only BattleTutorial content lookup.
- Regression infrastructure: Godot Runtime suite.

No combat formulas, skill definitions, rewards, roster rules, save schema, narrative facts, WorldMap gates, or global timeline values were changed.

## Files

- `scripts/combat/battle_tutorial.gd` (new)
- `ui/battle_ui.gd`
- `combat/test_battle_tutorial.gd` (new)
- `tests/runtime_suite.gd`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests

- New regression: `combat/test_battle_tutorial.gd` — PASS.
- Exact implementation/test SHA: `105e20cf4b4c3452673ef5025e1ec90d53adf8b2`.
- Godot Runtime run [44710429753](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44710429753) — **SUCCESS**.
- Job log explicitly reports `PASS res://combat/test_battle_tutorial.gd` and `RUNTIME_SUITE_PASS tests=59`.
- Godot project import, script registration, signature parser probe, EventRuntime and EventRunner checks all completed successfully in the same workflow.

## Godot Runtime status

**PASS — 59/59 registered runtime tests** on the exact implementation/test SHA above. This does not claim Web Demo export, Pages deployment, manual playtest, screenshot acceptance, or visual certification.

## Image-generation status

- The separate art-production branch PR #30 schedule assigns 2026-11-20 to the Tang Sanzang four-view turnaround. Its required gameplay crop is 128×192; the source must be a consistent transparent 2×2 turnaround sheet and follow the branch's prompt / crop / review contract.
- This session did not expose an executable image-generation tool. No image-generation call was made, no image credit was consumed by this session, and no placeholder or unreviewed image was committed as final art.
- No art source sheet, runtime crop, AssetCatalog entry, or SVG fallback was changed. PR #30 remains separate from this gameplay work.
- When image generation is available, follow the canonical art schedule and review/crop workflow rather than creating an unconstrained illustration.

## Known issues

- The tutorial is text-based; it does not yet highlight controls or pause the game with contextual arrows.
- The dismissed state is not persisted. If the player relaunches the same unfinished first encounter without a `battle_failed` marker, the automatic guide may appear again. The manual button remains available either way.
- No five-route full first-session playtest matrix or in-game screenshot review was performed in this batch.

## Next step

1. Extend the five-origin first-session acceptance matrix through New Game, opening sequence, first choice, first battle, defeat/retry, save/reload, and route convergence.
2. Decide whether the MainMenu “测试战斗” entry should be gated behind a developer-only option in public/demo builds.
3. Consider a safe export/backup flow for the single save slot.
4. Continue player-resolution and window-size screenshot review before declaring visual acceptance.

## Handoff point

Implementation is on `feature/shared-yellow-wind-mainline-2026-11-13`, PR #34. Keep PR #34 Draft/open; do not merge or deploy without owner approval. Start subsequent work from the latest docs-synchronized branch head and check its exact-SHA Runtime status. Preserve the fixed Journey chronology and the distinction between mainline Yellow Wind King and optional Yellow Fang bounty.
