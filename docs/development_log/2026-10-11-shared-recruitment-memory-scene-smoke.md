# 2026-10-11 · Shared Recruitment → Memory SceneTree Smoke

## Goal
Prove the first real recruitment-to-memory path end to end: Shared-03 victory recruits Bai Longma, unlocks his personal memories, and Journey can play one of those memories without replaying the battle or mutating the present.

## Starting point
- Read-only Memory playback passed its direct regression on implementation commit `fb7ece8f1af3f49aaeece9a31e3d1b62457df0eb`: Runtime [38107309910](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38107309910) passed 37 entries, and Web Demo [38107309919](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38107309919) build/deploy passed.
- The prior Shared battle SceneTree test already entered Shared-03 via production MainMenu/Journey/BattleUI, committed victory, returned to Journey and checked terminal END. It did not yet follow recruitment's actual memory unlock into the newly implemented playback entry.

## What changed
- Extended the Shared-03 case inside `combat/test_shared_battle_scene_transition.gd` to assert that production recruitment unlocks LONGMA-01 and LONGMA-02.
- Selects LONGMA-02 from the production Journey ItemList and uses the real playback button/path to display its opening dialogue and after-battle dialogue.
- Confirms memory replay does not transition to BattleUI, does not create active/pending battle handoff files, and preserves the complete non-memory NarrativeState. Only memory available/played flags may change at successful completion.
- Reloads the persisted save and verifies LONGMA-02 stays marked played while the current shared chapter remains Shared-04.

## Why
A feature can pass an isolated unit regression while being disconnected from the actual recruiting action. This stitches the existing recruitment transaction and the new Memory UI into one real scene smoke.

## Systems affected
- Shared-03 battle resolution and recruitment
- Memory unlock flags
- Journey sidebar / memory playback
- Save/load and SceneTree handoff regression

## Files
- `combat/test_shared_battle_scene_transition.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-shared-recruitment-memory-scene-smoke.md`

## Tests
- Existing Shared-03 / Shared-05 / Shared-07 scene transition cases remain.
- Shared-03 now includes the recruitment → memory unlock → read-only dialogue replay → explicit completion → save/load branch.
- Current registered suite remains at 37 entries because the new assertions extend the existing scene smoke.

## Godot Runtime status
**PENDING** — confirm the exact commit's Runtime and Web Demo workflows before recording this integration as passed.

## Known issues
- Memory replay intentionally presents safe dialogue only; it does not simulate old combat, apply old rewards, or replay historical choices.
- The smoke starts from canonical saved prerequisite state at Shared-03 rather than replaying the entire Wukong route from the very beginning. The separate Wukong route progression and MainMenu smoke cover that earlier part.

## Next step
After this integration passes, review the first product Vertical Slice from Wukong opening through Longma recruitment and identify whether the biggest remaining gap is exploration traversal, art assets, or encounter pacing before committing to the Camp / Relationship prototype.

## Handoff point
Recruitment-to-Memory scene bridge. Preserve the fixed shared chronology and keep historical playback read-only.
