# 2026-09-06 · Shared Battle Sequence Progression

## Session intent
Continue the JRPG Vertical Slice from the verified baseline, record every change in a fresh session document, and fix the next gameplay-critical progression gap before adding more content.

## Verified starting point
- Latest relevant code head: `259ac91dc94d937dcf32a31039d2eaa9d15e7019`.
- Godot Runtime #273 for `47a3d3d2c06e428100090f21ce52f0b98009b749`: SUCCESS.
- Web Demo #76 for `259ac91dc94d937dcf32a31039d2eaa9d15e7019`: SUCCESS.
- Repository tree confirms the project already contains the event-sequence runtime, shared journey manager, shared chapter data, battle bridge, camp/inventory services, and the visual asset catalog.

## Investigation
Reviewed:
- `docs/memory/PROJECT_MEMORY.md`
- `ui/journey.gd`
- `scripts/narrative/event_runner.gd`
- `scripts/narrative/event_sequence_definition.gd`
- `scripts/narrative/event_sequence_manager.gd`
- `scripts/narrative/shared_journey_manager.gd`
- `scripts/narrative/narrative_manager.gd`
- `data/narrative/shared_chapters.json`
- `data/narrative/event_sequences.json`
- `combat/test_shared_event_sequences.gd`
- `combat/test_journey_event_presentation.gd`

## Finding
`JourneyScreen._finish_event_session()` only called `SharedJourneyManager.complete()` when the finished sequence contained **no battle**. That condition was incorrect.

The canonical shared progression service already knows how to complete both combat and non-combat chapters. For combat chapters it requires the corresponding `SHARED_BATTLE_<encounter_id>` milestone, and then applies chapter completion, recruitment, world effects and the next chapter. Therefore the presentation layer should not suppress chapter completion merely because the sequence contained a battle.

This specifically affected the production sequences for:
- `SHARED-03-EAGLE-SORROW-SEQUENCE`
- `SHARED-05-GAOJIAZHUANG-SEQUENCE`
- `SHARED-07-FLOWING-SANDS-SEQUENCE`

## Change to make
1. Change Journey sequence completion policy from "shared + no battle" to "shared + matching current shared chapter".
2. Keep origin sequences out of shared chapter completion.
3. Add an integration regression in the Journey presentation test that executes a real shared battle sequence through battle resolution and then invokes `_finish_event_session()`.
4. Assert the shared chapter advances and the recruitment side effect is applied.
5. Run Godot Runtime and Web Demo again.

## Scope guard
No visual screen or AI art is being changed. This is a gameplay progression fix and remains compatible with the one-screen visual acceptance rule.

## Status at session start
- Investigation: complete.
- Implementation: pending.
- Regression: pending.
- CI: pending.
