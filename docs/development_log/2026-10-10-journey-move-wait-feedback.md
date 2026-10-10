# 2026-10-10 · Journey MOVE / WAIT Presentation

## Goal
Give movement and wait nodes a readable player-facing presentation while preserving the EventRunner / Service / Presentation boundary.

## Starting verification
- Victory-feedback correction commit 7ae2e6f41c627892ab3beb1533e8b0923081e12a passed Godot Runtime run 38042589835, with RUNTIME_SUITE_PASS tests=31.
- The next handoff named MOVE / WAIT feedback as the next narrowly scoped Journey presentation improvement.

## What changed
- Journey renders MOVE as a dedicated travel phase, describes the target map/marker, and shows a 前往 button with a short transition hint.
- WAIT renders a pause message, displays the effective duration, and explains that continuing will resume the story.
- Both MOVE and WAIT now enter a short presentation transition before event_session.complete_action() is called. This prevents the action from being committed before the transition and guards repeat clicks with event_transition_pending.
- Existing WorldActionService.apply_move() remains the canonical place where the world visit is recorded; EventRunner stays UI-independent.
- Extended combat/test_journey_event_presentation.gd to assert MOVE target/controls and WAIT duration/controls.

## Systems affected
- JourneyScreen event-action presentation
- Existing NarrativeEventSession and WorldActionService completion seam
- Journey event presentation regression

## Files
- ui/journey.gd
- combat/test_journey_event_presentation.gd
- docs/development_log/2026-10-10-journey-move-wait-feedback.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Added assertions to the existing Journey presentation test; tests/runtime_suite.gd already includes this script.
- Runtime job 38042773314 completed successfully on implementation commit ec58f239dfe46a2204727be142dfdc5717de0a70; the log confirms PASS for test_journey_event_presentation.gd and RUNTIME_SUITE_PASS tests=31.

## Godot Runtime status
**PASS for implementation commit ec58f239dfe46a2204727be142dfdc5717de0a70.** GitHub Actions runtime run 38042773314 completed successfully with RUNTIME_SUITE_PASS tests=31. The run emitted the existing missing-font and Resource/RID teardown diagnostics; these did not fail the suite.

## Known issues
- The last successful runtime run still emitted res://fonts/NotoSansSC-Regular.otf missing-font and Resource/RID teardown diagnostics. These did not fail the 31-test suite but are separate technical debt.
- The transition is a short text-led presentation, not a map-camera animation; adding full camera motion should be a separate visual acceptance batch.

## Next step
Next add END / chapter-completion feedback and its regression, keeping each presentation change small and avoiding side effects in EventRunner.

## Handoff point
MOVE is committed through JourneyScreen only after its presentation transition; WorldActionService remains the persistent world mutation boundary. WAIT likewise uses the same presentation transition before completing the action.
