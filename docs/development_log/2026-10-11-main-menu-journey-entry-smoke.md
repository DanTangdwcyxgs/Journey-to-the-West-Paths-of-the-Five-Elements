# 2026-10-11 · Main Menu → Journey SceneTree Smoke

## Goal
Verify a real entry path across the production MainMenu and Journey scenes, not only their pieces in isolated service tests.

## Starting verification
- Teardown cleanup commit `ff50907c95cb5017a8fdad4b2ee27ee773c37ac5` passed Godot Runtime run [38103322441](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103322441), `RUNTIME_SUITE_PASS tests=32`.
- After explicit Node cleanup, the Runtime log no longer emitted Canvas RID, CanvasItem RID, Viewport, TextServer RID, or "resources still in use" warnings; only `ObjectDB instances leaked at exit` remains. This strongly supports the detached UI tree as the source of the previous renderer/text resource flood, but the remaining ObjectDB warning is not considered resolved.
- Web Demo run [38103322430](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38103322430) passed.

## What changed
- Added `combat/test_main_menu_journey_entry.gd` as a SceneTree integration smoke test.
- The test creates the production MainMenu, starts a Wukong route through its real new-game handler, waits for the production `journey.tscn` transition, verifies the saved character state, then advances into the production `WUK-01-SEQUENCE`.
- To avoid damaging a developer save when running the suite locally, the smoke test snapshots and restores the narrative save slot and both `BountyEncounterState` handoff files; generated test nodes are freed before exit.
- Added the smoke test to `tests/runtime_suite.gd`.
- Updated the persistent handoff to make the route entry smoke explicit.

## Systems affected
- SceneTree integration / Presentation entry path
- Existing NarrativeSave and BountyEncounterState persistence boundaries, only isolated/restored by the test harness
- Runtime regression suite and handoff

## Files
- `combat/test_main_menu_journey_entry.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-10-11-main-menu-journey-entry-smoke.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/2026-10-11-runtime-test-node-teardown.md`

## Tests
- The new SceneTree test checks route start/save, MainMenu → Journey transition, selected start character persistence, and entry into the actual WUK-01 production Sequence.
- Requires the exact new-head GitHub Actions Runtime result before declaring PASS.

## Godot Runtime status
PENDING until the SceneTree smoke is executed in Godot 4.5.1 CI.

## Known issues
- Runtime still reports one generic ObjectDB leak warning at exit. The detailed leaked Object list has not yet been isolated.
- This smoke covers the route-entry path only; full Battle → resume → END → Save remains covered by dedicated bridge/progression tests and can receive a separate broader scene test.

## Next step
Check new-head Runtime. If the new test passes, record the main menu entry chain as directly smoke-tested and investigate the remaining ObjectDB warning using targeted diagnostics rather than global warning suppression.

## Handoff point
SceneTree entry / save boundary. Narrative chapter and sequence rules remain owned by NarrativeManager and EventSequence infrastructure.
