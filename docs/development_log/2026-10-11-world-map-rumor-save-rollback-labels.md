# 2026-10-11 · WorldMap Rumor Save Rollback and Player-Facing Bounty Labels

## Goal
Make rumor discovery transactional with its save, and ensure the optional bounty UI uses player-facing names and explicitly communicates that bounties do not advance the mainline.

## Starting point
- The WorldMap free-travel path already snapshots NarrativeState and restores it when saving a destination fails.
- Audit of `ui/world_map.gd` found `_hear_rumor()` changed heard-rumor and bounty-discovery state, ignored the return value from `narrative.save()`, then refreshed the UI as if discovery had committed. A failed save could consume the rumor in memory while losing the discovery after reload.
- The bounty list displayed internal IDs such as `BOUNTY_YELLOW_FANG`, and the UI label did not explicitly state that these are optional side objectives separate from the canonical Shared Journey.

## What changed
- `WorldMapScreen._hear_rumor()` now snapshots NarrativeState before applying rumor effects, restores it on save failure, and leaves the rumor available to retry.
- WorldMap loads the existing bounty definitions and renders the player-facing bounty name rather than the internal ID.
- The bounty label now explicitly reads “可选悬赏（不推进西游主线）”.
- Added a save-failure / retry SceneTree regression for rumor discovery and strengthened the production rumor-to-bounty smoke with UI wording assertions.

## Why
Rumor discovery is a persistent world-state transition. It must not be reported as completed unless its save succeeds. Optional combat targets should be understandable to players without exposing implementation identifiers or suggesting that the main story is blocked behind them.

## Systems affected
- WorldMap rumor discovery and save rollback
- Optional bounty presentation
- Production SceneTree Runtime suite

## Files
- `ui/world_map.gd`
- `combat/test_world_map_rumor_save_failure_rollback.gd`
- `combat/test_world_map_rumor_bounty_return.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-world-map-rumor-save-rollback-labels.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- New test forces rumor-save failure, checks the entire serialized state is restored, and retries successfully.
- Existing production WorldMap → rumor → bounty → return → Journey → Shared-05 smoke now asserts player-facing bounty naming and explicit optional/mainline separation.
- Runtime suite expected registered entries: 48.

## Godot Runtime status
**PENDING** — this branch's exact-head GitHub Actions run must complete before claiming validation. Do not infer Runtime success from static inspection.

## Known issues
- This regression injects the save result instead of simulating a partial filesystem write.
- Existing rumor discovery supports the current data-driven rumor schema; it does not add a general quest journal or new bounty routing.

## Next step
Confirm exact-head Godot Runtime, inspect the new regression's log, then continue auditing optional exploration pacing and the next vertical-slice interaction.

## Handoff point
Keep rumor discovery, heard-rumor markers, and bounty availability in one save transaction. Keep the mainline chapter/timeline authoritative and make optional objectives visibly optional.
