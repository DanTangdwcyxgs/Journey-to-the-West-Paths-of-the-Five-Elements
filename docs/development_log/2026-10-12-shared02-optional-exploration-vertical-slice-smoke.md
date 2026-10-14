# 2026-10-12 · Shared-02 Optional Exploration Vertical-Slice Smoke

## Goal
Verify the newly signposted optional exploration in the same saved production-UI journey, then reconnect cleanly to the canonical Shared-03 Eagle Sorrow sequence.

## Starting point
- Round 62 added the Shared-02 map/rumor signpost, localized map presentation, and save-atomic rumor discovery.
- The existing full-arc SceneTree smoke went directly from Shared-02 to Shared-03, while the WorldMap rumor/bounty smoke started from a later Shared-05 fixture. The exact newly intended transition was not yet covered as one production UI flow.

## What changed
- Extended the existing single-save production SceneTree smoke so that, after Shared-02 completes, it opens WorldMap through Journey's real map button.
- The smoke travels from Five Elements Mountain to Eagle Sorrow, hears the Yellow Fang rumor through the real controls, reloads the saved narrative state, and returns through the production Return to Journey button.
- It then continues the real Shared-03 sequence and Longma battle as before.
- Added assertions that optional travel and rumor discovery preserve the current Shared chapter, canonical timeline, completed chapter history, and recruited roster, while only the world location / heard-rumor / discovered-bounty state changes.

## Why
The player-facing signpost should lead to a real, reversible detour—not merely display correct dialogue. This closes the integration gap between the completed Shared-02 sequence, free exploration, persisted rumor discovery, and the next canonical story beat.

## Systems affected
- Production Journey → WorldMap → Journey scene transitions
- WorldMap connected-node travel and rumor discovery
- Same-save Shared chronology and recruitment smoke coverage

## Files
- `combat/test_shared_opening_to_black_wind_smoke.gd`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`
- `docs/development_log/2026-10-12-shared02-optional-exploration-vertical-slice-smoke.md`

## Tests
- The existing registered `test_shared_opening_to_black_wind_smoke.gd` now covers Shared-02 → production WorldMap → Eagle Sorrow rumor → Journey → Shared-03 → Longma battle.
- Assertions compare chapter ID, global timeline, completed Shared history, and recruited roster before and after travel/rumor discovery, plus verify reloadable persistence.
- Runtime suite registration count remains 49; no separate test entry was added.
- Exact implementation SHA Runtime result: pending CI; no local Godot executable was run from this connector session.
- Web Demo result: pending the main-branch push after merge.

## Godot Runtime status
**PENDING** — must be confirmed on the exact pull-request implementation SHA. The previous main/PR history is not evidence for this new integration.

## Web Demo status
**PENDING** — the Web Demo workflow runs on a push to `main`, not on a pull request. Verify build/export/deploy after merge.

## Known issues
- This integration smoke intentionally verifies rumor discovery but does not launch or resolve the optional bounty battle; the existing WorldMap production smoke independently covers the bounty battle and return path.
- The user-facing flow is covered by SceneTree automation, but a human pacing/art pass is still needed on Shared-02 → map detour → Shared-03.

## Next step
Run and inspect Godot Runtime for the exact implementation SHA. If it passes, merge through the repository PR workflow, then verify the main-branch Runtime and Web Demo build/deploy before moving on to region-entry interactions and final character-art review.

## Handoff point
The same-save production smoke now exercises the optional detour at the actual narrative handoff point. The next canonical sequence remains Shared-03 Eagle Sorrow; optional travel and rumor discovery must not advance the global chronology or alter recruitment.


## 2026-10-14 Rebase and Validation Update

### Dependency resolution
- PR #25 was merged after explicit owner authorization at squash commit 9c8ca5742ef32af72d480c06e8f5a6e20196e12a. It includes the intended timeline-105 availability for the optional Eagle Sorrow map node and Yellow Fang rumor, while keeping Shared-03's canonical milestone at timeline 110.
- The original PR #26 implementation SHA cefaf8e5283accf5c8d9808f1698e75ad2363731 failed its exact-SHA Runtime run because its tested main base did not yet contain that dependency. The first failing assertion was Eagle Sorrow reachability; the assertion is correct and was not loosened.
- Reapplied the existing SceneTree regression onto the post-PR-25 main base. The flow still uses production Journey/WorldMap controls and verifies location/rumor persistence without mutating Shared chapter, global timeline, completed chapter history, or roster.

### Current validation gate
- Integrated Runtime suite expected count: 50 entries (PR #25 introduced an additional registered regression).
- Rebased PR head: pending exact-SHA GitHub Actions Runtime validation. No local Godot execution is claimed. The old PR #26 failure remains historical evidence and is not counted as validation of this rebased head.
- Web Demo: not expected on this feature branch; must be verified on the post-merge main push.

### Next-agent entry point
Inspect the latest Runtime workflow for PR #26's current head. Require the exact-head RUNTIME_SUITE_PASS tests=50 result and inspect the job log before marking ready or merging. Then validate the new main SHA Runtime plus Web Demo build/export/deploy. Continue region entry / interactive exploration and final character asset review only after recording those real results.