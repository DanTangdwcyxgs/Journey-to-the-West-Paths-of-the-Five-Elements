# 2026-10-11 · Battle Resume Terminal Handoff Cleanup

## Goal
Avoid reviving a completed narrative battle after END. Keep terminal-state cleanup separate from handoff-preserving cleanup.

## Starting evidence
- Commit 4102cab's production SceneTree smoke caught a post-victory feedback failure. Parent commit 959a32f fixed NarrativeBattleUI's duplicate advance and passed Runtime run 38104519997 (35 test entries) plus Web Demo run 38104519990.
- The production END handler still called generic BountyEncounterState.clear(), which intentionally migrates active event_resume data into the pending resume file. That is correct during some handoffs but wrong after a sequence is terminal.

## What changed
- Added BountyEncounterState.clear_completed_event_session(), which removes both the active encounter handoff and pending resume file without copying either into the other.
- Journey and OriginSequenceJourneyScreen now use that terminal cleanup for their END/chapter-completion paths and surface cleanup failures in the completion notice.
- Extended the real MainMenu → WUK-02 battle/resume SceneTree smoke to assert no active/pending resume files remain after END.
- Updated the shared battle bridge test cleanup: because that regression stops before production END, it must discard its temporary continuation instead of persisting a stale resume.
- Updated the handoff and AI memory so image generation does not block framework work; no concept sheet is treated as production art.

## Why
The generic clear API has backward-compatible handoff semantics; changing it globally would break valid scene continuations. A dedicated terminal API makes ownership explicit and lets regressions verify a clean terminal state.

## Systems affected
- World handoff compatibility state
- Journey / Origin Journey presentation lifecycle
- Shared and Origin SceneTree regressions
- Development log and AI handoff

## Files
- scripts/world/bounty_encounter_state.gd
- ui/journey.gd
- ui/origin_sequence_journey.gd
- combat/test_main_menu_battle_resume_smoke.gd
- combat/test_shared_battle_journey_bridge.gd
- docs/development_log/2026-10-11-main-menu-battle-resume-smoke.md
- docs/development_log/2026-10-11-battle-resume-terminal-cleanup.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Runtime run 38104519997 passed 35 entries after fixing the double-advance issue.
- Terminal assertions require the active and pending resume files to be absent after END.
- Exact-head Runtime and Web Demo for the terminal-cleanup implementation commit ea24dd2 are pending.

## Godot Runtime status
PENDING until Actions finish for the exact implementation SHA.

## Known issues
- Any other END call site must use clear_completed_event_session(); generic clear() intentionally preserves continuation by design.
- Final PNG/WebP character assets remain deferred because image generation was unavailable; no concept illustration is being treated as production art.

## Next step
Check exact-head Runtime and Web Demo. Fix any remaining real failures before extending the shared recruitment battle SceneTree path.

## Handoff point
Narrative / Presentation scene lifecycle. Canonical progression and rewards remain owned by OriginRouteManager / BattleResolutionService.
