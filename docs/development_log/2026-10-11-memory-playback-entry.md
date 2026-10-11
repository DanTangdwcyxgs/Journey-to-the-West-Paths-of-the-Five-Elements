# 2026-10-11 · Read-Only Memory Playback Entry

## Goal
Turn the existing recruitment-unlocked Memory IDs into a real Journey UI playback path while preserving the current shared Journey state.

## Starting point
- Recruitment already places eligible Origin chapter IDs in `NarrativeState.available_memory_chapters`.
- Journey displayed those IDs as `回忆 · LONGMA-01`, but the click handler looked for a different `回忆:` prefix.
- More importantly, the dynamic Journey UI never instantiated its declared `list` ItemList, and the current click path immediately called `begin_memory()`, `finish_memory()` and `save()` with no content presentation.
- Project canon requires Memory / flashbacks to preserve the fixed global chronology and exact shared state.

## What changed
- Added `scripts/narrative/memory_playback_session.gd`, a read-only dialogue extractor for unlocked Origin sequences. It follows the main graph path, presents dialogue nodes only, skips choices/battle/reward/world-action nodes, and uses the Origin chapter summary as a fallback.
- Journey now creates a visible chapter / unlocked-memory ItemList. Selecting an unlocked memory enables the playback button.
- Memory playback uses the existing typewriter dialogue panel and explicit “继续回忆” / “完成回忆” actions. World-changing UI controls and manual save are disabled while a memory is active; Back remains available to abandon playback without recording it.
- Only the final explicit action calls `finish_memory()` and saves. Shared context is checked before commit; a save failure restores the whole pre-playback NarrativeState and keeps the final entry available for retry.
- Added `combat/test_memory_playback.gd` to cover real Journey widget creation, the list-to-session entry, dialogue-only playback of a sequence that contains a battle, chronology/roster invariants, and save-failure retry.

## Why
Unlock flags alone do not deliver a Memory experience. Reusing EventRunner would execute choices and battles and risk modifying the present; simply marking a chapter as played skips the feature entirely. A read-only projection of canonical dialogue reuses approved story content without performing historical side effects.

## Systems affected
- Journey Presentation / chapter sidebar
- Narrative Memory playback projection
- Memory available/played persistence boundary
- Godot Runtime regression suite

## Files
- `scripts/narrative/memory_playback_session.gd`
- `ui/journey.gd`
- `ui/origin_sequence_journey.gd`
- `combat/test_memory_playback.gd`
- `tests/runtime_suite.gd`
- `docs/architecture.md`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-memory-playback-entry.md`

## Tests
- The new test opens the production Journey scene shell, selects the unlocked LONGMA-02 memory and validates both canonical dialogue entries while never executing its choice or battle node.
- A failed save must restore the exact serialized state and keep playback active; a successful retry updates only the available/played memory flags.
- Runtime suite expected registered entry count: 37.

## Godot Runtime status
**PENDING** — only mark this batch green after Godot Runtime and Web Demo complete on the exact implementation commit.

## Known issues
- This first increment replays canonical text dialogue, not character sprites, voice performance, battle simulation or route-dependent alternate dialogue branches.
- A memory with no executable Origin Sequence dialogue uses its legacy chapter summary as a safe fallback.
- The memory list is scoped to the current Journey screen; a dedicated Memory Gallery / replay of already-played memories remains future work.

## Next step
After the exact SHA passes, add an end-to-end recruitment-to-memory test (Shared-03 victory unlocks Longma memory, then Journey opens it) and evaluate the first full Wukong → Longma vertical slice.

## Handoff point
Read-only Memory presentation and save boundary. Do not execute EventRunner actions during flashback playback or mutate world chronology.
