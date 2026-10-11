# Shared-02 Optional Exploration Signpost

## Goal
Give players a clear, low-pressure cue that optional exploration is available after the short early-pilgrimage interlude, without obscuring the canonical next destination: Eagle Sorrow.

## Starting point
SHARED-02 was a compact choice and two dialogue beats ending immediately after Wukong's line. Its text did not signal that the player could use the world map to investigate optional rumors between completed story sequences. The production chronology already places SHARED-03 Eagle Sorrow next, so optional activity must remain explicitly secondary.

## What changed
- Added a short Wukong dialogue node after the existing SHARED-02 choice and travel line.
- The line points players to the map and nearby rumors as optional exploration, while explicitly reminding them that Eagle Sorrow remains the next mainline destination.
- Extended the production Shared sequence runtime regression to assert the new node appears and includes the map, rumor, and Eagle Sorrow cues.
- Updated AI memory, handoff, and development-log index.

## Why
The interlude should create breathing room between the Five Elements Mountain opening and Longma's recruitment, but not make players guess whether side content is available or mistake a bounty for the next canonical chapter. This small signpost improves discoverability without adding a new branch, state flag, reward, or chronology mutation.

## Systems affected
- Shared-02 production EventSequence dialogue content.
- Existing Shared event sequence runtime regression.
- No world state, save schema, route order, optional-bounty rules, or battle handoff behavior changed.

## Files
- data/narrative/event_sequences.json
- combat/test_shared_event_sequences.gd
- docs/development_log/2026-10-11-shared02-exploration-signpost.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Existing sequence runtime test now checks that the SHARED-02 exploration node mentions the map, optional rumors, and Eagle Sorrow as the next mainline destination.
- Godot Runtime CI: PENDING for this branch head.

## Known issues
- The signpost is a dialogue cue, not a new map marker or a forced tutorial. It assumes the existing World Map control and rumor/bounty discovery surfaces are available after the sequence completes.
- This does not expand the actual optional content catalog.

## Next step
After exact-head Runtime passes, continue auditing whether the world map and rumor UI make optional activities understandable while preserving the next required Shared chapter.

## Handoff point
SHARED-02 now tells players where optional exploration lives and reminds them not to lose sight of Eagle Sorrow. Keep SHARED-03 as the canonical next chapter and keep optional Yellow Wind bounty content distinct from the planned full Yellow Wind Ridge mainline.
