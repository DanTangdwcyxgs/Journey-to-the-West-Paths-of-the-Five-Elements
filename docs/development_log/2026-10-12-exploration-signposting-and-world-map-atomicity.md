# 2026-10-12 · Shared Opening Exploration Signposting and WorldMap Atomicity

## Goal
Make the first shared journey segment clearer and safer to explore: signpost optional rumors after Shared-02 without changing the next canonical chapter, show player-facing destination and bounty names, prevent exiting an active EventSequence through destructive navigation, and roll back failed rumor discovery saves.

## Starting point
- The last integrated vertical slice passes WUK-15 → Shared-01..04 → Longma Memory, but the production Shared-02 dialogue did not tell players how to find optional rumors between completed sequences.
- Journey MOVE UI exposed internal map/marker IDs such as `BLACK_WIND_NORTH_PATH` instead of the localized destination.
- Journey navigation controls remained enabled during an active EventSequence, while scene transitions do not serialize the active runner; leaving could drop current progress.
- WorldMap rumor discovery mutated NarrativeState and ignored save failure, while bounty rows exposed internal IDs and did not clearly say that optional bounties do not advance the mainline.

## What changed
- Added a short Wukong signpost to the production Shared-02 sequence. It invites players to use the map for rumors while explicitly keeping Eagle Sorrow as the next story destination.
- Journey MOVE prompts resolve `marker_id` through `WorldMapManager` and display a localized destination name, with an ID fallback only for unknown catalog entries.
- Journey locks Party, World Map, manual Save and Return-to-Menu controls while an EventSequence action is active. The main action remains available; navigation unlocks when the normal route/shared overview returns. The error/empty-action state remains escapable.
- WorldMap now loads the existing bounty definitions, displays player-facing bounty names, and labels them “可选悬赏（不推进西游主线）”.
- Rumor discovery snapshots the complete NarrativeState before applying effects. If save fails, it restores the snapshot, refreshes UI to preserve the rumor for retry, and shows explicit failure feedback.
- Added regression coverage for signpost wording, localized MOVE destination, navigation lock/unlock, optional bounty wording, and rumor save failure + successful retry.

## Why
Optional exploration should be discoverable without feeling mandatory or interrupting the canonical journey. The save boundary also needs to match the player-facing result: a rumor is not consumed and a bounty is not discovered until its state commits.

## Systems affected
- Shared-02 EventSequence presentation content
- Journey navigation safety and MOVE wording
- WorldMap bounty labels and rumor persistence
- SceneTree / EventRunner regressions

## Files
- `data/narrative/event_sequences.json`
- `ui/journey.gd`
- `ui/world_map.gd`
- `combat/test_journey_event_presentation.gd`
- `combat/test_shared_event_sequences.gd`
- `combat/test_world_map_rumor_bounty_return.gd`
- `combat/test_world_map_rumor_save_failure_rollback.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- Shared EventRunner must execute the Shared-02 signpost and assert map + rumor + Eagle Sorrow wording.
- Journey presentation regression must assert localized “目的地：黑风山北道”, no leaked marker ID, active-sequence navigation lock and released navigation.
- WorldMap smoke must assert the displayed bounty name and explicit optional/mainline distinction.
- New SceneTree regression forces rumor save failure, compares the entire pre/post NarrativeState snapshot, verifies rumor/bounty discovery rollback, then retries successfully.
- Expected registered Runtime suite entries: 49.

## Godot Runtime status
**PENDING** — verify the exact implementation SHA. Do not treat prior branch CI as validation of this combined integration.

## Web Demo status
**PENDING** — this PR workflow does not run Web Demo for pull requests. Validate build/export/deploy on the main-branch push after merge.

## Known issues
- Rumor rollback is covered with an injected save result rather than a partial filesystem-write failure.
- The conservative Journey navigation lock avoids dropping a live runner but does not implement general-purpose mid-sequence serialization; a future session handoff requires its own save/resume regression.
- Final character PNG/WebP assets remain separate art work; this batch deliberately does not re-label placeholder SVGs as final art.

## Next step
After exact-SHA Runtime and main-branch Web Demo validation, manually review the playable Shared-02 → optional exploration → Shared-03 transition and then continue the vertical slice's region-entry/interaction and final-art review.

## Handoff point
The player now receives an explicit optional-exploration cue after Shared-02; map travel remains a between-sequence activity, the Eagle Sorrow chronology remains canonical, and rumor discovery is only reported after its save commits.
