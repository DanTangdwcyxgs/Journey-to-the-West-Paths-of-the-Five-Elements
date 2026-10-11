# Journey Event Navigation Lock

## Goal
Prevent players from leaving Journey while a production EventSequence is active and losing its in-memory runner position.

## Starting point
Journey's party, world-map, manual-save, and return-to-menu buttons remained enabled while a sequence was presenting dialogue, choices, MOVE, WAIT, battle handoff, or END. The map/menu callbacks switch scenes directly, while the active NarrativeEventSession is held only in the Journey instance except for the established battle-resume handoff. Leaving mid-sequence could discard that uncompleted presentation state and replay nodes on re-entry.

## What changed
- Added a shared navigation-lock helper for the party, world-map, manual-save, and return-to-menu buttons.
- Lock those controls whenever Journey renders an active EventSequence action; keep the primary action available so the sequence can progress normally.
- Unlock navigation when Journey returns to the normal route/shared overview after the sequence is finished.
- Reuse the same helper for read-only Memory playback controls, preserving its existing no-navigation-while-playing behavior.
- Extended Journey presentation regression to assert all four controls are locked during an active event and can be unlocked afterward.
- Updated AI memory, handoff, and development-log index.

## Why
The current scene transition callbacks do not serialize the active EventRunner. Until a general-purpose serializable Journey-session handoff exists, disabling destructive scene exits during active event presentation is the smallest safe boundary. This does not prevent optional exploration after a sequence ends.

## Systems affected
- Journey Presentation navigation controls only.
- EventSequence in-memory lifecycle boundary.
- Regression coverage for Journey controls.

## Files
- ui/journey.gd
- combat/test_journey_event_presentation.gd
- docs/development_log/2026-10-11-journey-event-navigation-lock.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Regression now checks World Map, Party, Save, and Return-to-Menu disabled state while a MOVE action is active.
- Godot Runtime CI: PENDING for this branch head; exact-head CI must finish before the batch is considered validated.

## Known issues
- This protects the visible buttons; it does not introduce a serializable Journey session or support deliberate mid-sequence scene suspension.
- The sidebar remains visible, but Memory playback cannot start while an event action is active because its button is disabled.

## Next step
After Runtime passes, continue reviewing the Shared-02 → Shared-03 pacing and optional exploration signposting. Keep map exploration available between completed sequences and preserve the canonical Shared chapter order.

## Handoff point
Active EventSequence presentation now locks navigation exits instead of silently dropping the runner. A future general-purpose scene/session handoff can replace this conservative lock once it has explicit save/resume regression coverage.
