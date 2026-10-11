# 2026-10-11 · Main Menu → Origin Battle → Resume Smoke

## Goal
Upgrade the existing MainMenu route-entry smoke into a real scene-switching test across origin battle handoff, atomic victory, narrative resume, END, and save.

## Starting verification
- The preceding framework/docs cleanup commit `e736514c75733055354aa175e1dfa2c6d77ca775` passed Godot Runtime [38104295024](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104295024) and Web Demo [38104295034](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104295034).
- Its verified suite had 34 passing test entries; the ObjectDB/Canvas/TextServer leak diagnostics were no longer present after switching generated SFX from a permanent AudioStreamGenerator to finite queued WAV clips.

## What changed
- Added a new SceneTree smoke that starts a Wukong route through production MainMenu.
- It advances actual WUK-01 dialogue/END in OriginSequenceJourneyScreen and checks that the route cursor advances to WUK-02.
- It enters the production WUK-02 battle node and requires the real scene transition to battle_ui.tscn with canonical encounter WUKONG_ORIGIN_WATER_CAVE, chapter WUK-02, and event_resume payload.
- It triggers the production NarrativeBattleUI victory handler, checks the battle result summary, and uses the real return button to switch back to Journey.
- It verifies the resumed production EventSession continues the WUK-02 after-battle dialogue, that the saved chapter cursor is WUK-03 after victory, then advances through END and validates a loadable save without double-advancing the chapter.
- The test snapshots/restores narrative save, active encounter handoff, and pending resume files so the test does not replace local developer state.
- Registered the new test in tests/runtime_suite.gd, updated AI_MEMORY and AI_HANDOFF, and indexed this log.

## Systems affected
- SceneTree / production scene transitions
- Origin EventSequence → EncounterHandoff → NarrativeBattleUI → BattleResolutionService → Journey resume
- Save and event-resume persistence, tested via existing owners

## Files
- combat/test_main_menu_battle_resume_smoke.gd
- tests/runtime_suite.gd
- docs/development_log/2026-10-11-main-menu-battle-resume-smoke.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Initial Runtime run [38104441392](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104441392) on commit 4102cab failed at the post-victory story-feedback assertion; the assertion revealed a production behavior issue and was not weakened.
- Parent correction commit [959a32f](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/commit/959a32f06a389ce460d015d16192cb673c0240f2) passed Runtime run [38104519997](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104519997) with RUNTIME_SUITE_PASS tests=35 and Web Demo run [38104519990](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38104519990).
- Follow-up commit ea24dd2 adds END assertions that both active and pending resume files are absent. Its exact-head Runtime / Web Demo are pending while this log is updated.

## Known issues
- The test intentionally invokes the existing production victory handler with an "allies" winner instead of simulating every individual turn input. It validates the real handoff, battle scene, atomic resolver, return navigation, resume and save path; combat turn mechanics remain covered by their dedicated combat tests.
- The full shared battle handoff still has its existing dedicated regressions. This new test targets an Origin route started from the actual MainMenu.

## Next step
Check exact-head Runtime and Web Demo. If the new smoke passes, the project will have a directly verified MainMenu → Origin Battle → Resume → END/Save scene path; then move on to cross-reference validation or failure-path rollback, using a separate scoped regression.

## Handoff point
Narrative / Presentation SceneTree integration. Progression and atomic rewards stay in BattleResolutionService and OriginRouteManager.
