# 2026-10-11 · Shared Recruitment Battle Real SceneTree Smoke

## Goal
Upgrade shared recruitment-battle integration coverage from adjacent scenes instantiated by a test helper to real production scene transitions through MainMenu, Journey, BattleUI and back.

## Starting point
- `combat/test_shared_battle_journey_bridge.gd` already exercised three canonical recruitment battles, battle settlement, EventSession serialization and resumed dialogue.
- That test manually instantiated BattleUI and Journey and called the Journey session restore method, so it did not prove that the production scene-change callbacks and return button preserved the handoff end to end.
- Preceding hardening is green: full EventSequence catalog gate passed Runtime run [38105696943](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105696943); BattleResolutionService save-failure rollback passed Runtime run [38105806758](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105806758) and Web Demo run [38105806791](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38105806791).

## What changed
- Added `combat/test_shared_battle_scene_transition.gd` and registered it in `tests/runtime_suite.gd`.
- Covered Shared-03 / Eagle Sorrow / Longma, Shared-05 / Gaojiazhuang / Bajie, and Shared-07 / Flowing Sands / Wujing.
- Each case builds canonical prior-chapter/recruitment state, saves it, uses production MainMenu Continue, advances the actual Journey UI to the canonical choice, clicks the rendered choice button, then waits for the real BattleUI scene.
- The test invokes the production victory callback, checks the canonical reward/progression/recruitment summary, presses the real “继续旅途” button and verifies the production Journey scene restores the after-battle EventSession.
- It continues through actual END handling and checks active / pending handoff cleanup, the persisted recruited companion, chapter completion and no double advancement.
- The test backs up and restores the narrative save and both handoff files.

## Why
The previous bridge regression verified service interactions but could miss bugs in scene replacement, UI callbacks, or `_ready()` restoration. Production scene transitions are the layer that joins these pieces for a real player.

## Systems affected
- Shared Journey UI / scene transitions
- BattleUI victory handoff
- EventSession persistence and recovery
- Runtime regression suite

## Files
- `combat/test_shared_battle_scene_transition.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-shared-battle-scene-transition-smoke.md`

## Tests
- New dedicated smoke covers all three Shared recruitment battles.
- The existing Shared bridge regression remains in the suite and continues to test session/reward details across the three cases.
- The test is isolated in a child Godot process by the runtime suite and restores files it touches.

## Godot Runtime status
**PASS** — exact implementation commit `895ee2b3324aae7cde21a6a41b74c882dfae7227`. Godot Runtime run [38106171552](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106171552) passed with `PASS res://combat/test_shared_battle_scene_transition.gd` and `RUNTIME_SUITE_PASS tests=36`. The same SHA's Web Demo run [38106171496](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106171496) also passed.

## Known issues
- The test prepares earlier chapters through canonical managers/resolution service; it starts each target battle from a valid saved prerequisite state rather than replaying the entire pilgrimage from chapter 01.
- Combat turns are shortcut by invoking the production battle completion callback, consistent with the existing WUK-02 SceneTree smoke; the test targets the handoff / scene / resolution boundary, not combat balance.
- It does not simulate a process crash in the middle of OS-level file writes.

## Next step
The real scene-transition smoke passed. Chapter metadata / namespace consistency is the follow-up batch in `2026-10-11-event-sequence-namespace-metadata-consistency.md`; after that passes, reassess the Wukong-to-Longma vertical slice and Memory entry point.

## Handoff point
Production UI / SceneTree integration. Keep EventRunner UI-independent and keep rewards, recruitment and shared chronology owned by the existing resolution / chapter managers.
