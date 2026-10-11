# 2026-10-11 · Runtime Test Node Teardown

## Goal
Investigate, rather than hide, Godot Runtime teardown diagnostics after the font-contract fix.

## Evidence
- Runtime commit `4b383b1230d19f5eaeb616823bd08e368311592c` passed `RUNTIME_SUITE_PASS tests=32`, but its log still reported 49 leaked CanvasItem RIDs, one Canvas RID, a Viewport, TextServer shaped text/font RIDs, ObjectDB instances, and resources still in use.
- `combat/test_main_menu_contact.gd` runs its static `run_all()` in the suite's long-lived SceneTree process. It instantiated and built a complete MainMenu Control subtree plus a detached AcceptDialog, then returned without freeing either Node. This is a concrete lifecycle leak candidate, and the CanvasItem count is consistent with the large menu subtree.
- `combat/test_pixel_ui_font_contract.gd` queued the HUD for deletion and immediately quit its SceneTree without waiting for the queued deletion to be processed.

## What changed
- Explicitly free the detached contact dialog and the MainMenu root before the static test returns.
- Wait one SceneTree frame after queue_free() in the font contract test before quitting.

## Why
Tests must clean up the Nodes they create. Fixing test lifetime is safer than changing production UI or forcing resource release globally. This is a hypothesis-driven cleanup, not a claim that all teardown warnings are now solved.

## Files
- `combat/test_main_menu_contact.gd`
- `combat/test_pixel_ui_font_contract.gd`
- `docs/development_log/2026-10-11-runtime-test-node-teardown.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- Await exact new-head GitHub Actions Runtime logs; compare CanvasItem / Canvas / TextServer / ObjectDB diagnostics to the prior 32-test successful run.

## Godot Runtime status
PENDING until the current implementation SHA has finished GitHub Actions.

## Remaining questions
- Other UI subtree/static-test lifetime leaks may remain.
- Resource or TextServer diagnostics are tracked independently; do not globally suppress warnings or call them fixed based on passing tests.

## Next step
Inspect the exact new Runtime job log. If the CanvasItem warning is gone or lower, isolate remaining diagnostics by test cohort. Otherwise examine other static `run_all()` tests for detached Nodes that are not freed.

## Handoff point
Runtime test harness / SceneTree lifetime, not game Domain or Narrative code.
