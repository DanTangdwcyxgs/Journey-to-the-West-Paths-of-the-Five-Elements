# 2026-10-11 · BattleUI Bounty Settlement Retry Button Regression

## Goal
Verify that a failed bounty settlement can be retried through the production BattleUI button, without replaying combat or committing rewards twice.

## Starting point
- Main head before this batch: `69c162913800f49345ed4b61e679f3484c5a1a0c`.
- The previous atomicity regression already covers rollback of NarrativeState, inventory, journal, BountyManager state, and successful service retry.
- The remaining gap was the presentation-to-service interaction: no regression clicked the actual “重试结算” Button signal.

## What changed
- Added narrow overridable BattleUI boundaries for loading the narrative state, requesting bounty settlement, and clearing the handoff. Production implementations still delegate to `NarrativeManager`, `BountyRewardService.resolve_defeat()`, and `BountyEncounterState.clear()`.
- Added `combat/test_bounty_settlement_retry_button.gd`. Its test double forces the first settlement attempt to fail, then emits the actual `return_button.pressed` signal. It checks retry state, one successful commit, success feedback, and unchanged combat turn count.
- Registered the regression in `tests/runtime_suite.gd`.
- Updated the handoff point and development log index.

## Why
Atomic service rollback alone does not prove the production button re-enters settlement correctly. The UI must allow retry after a save failure while preserving the already-finished battle and avoiding duplicate rewards.

## Systems affected
- BattleUI post-victory result/retry orchestration
- BountyRewardService integration boundary (production path unchanged)
- Godot headless runtime regression suite
- AI handoff / persistent development memory

## Files
- `ui/battle_ui.gd`
- `combat/test_bounty_settlement_retry_button.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/2026-10-11-bounty-settlement-retry-button.md`

## Tests
- Expected runtime suite entries: 48.
- First settlement attempt returns no result and must expose the retry button without resolving the encounter.
- Emitting the actual Button `pressed` signal must invoke settlement a second time.
- Exactly one successful commit is allowed, and the combat turn counter must remain unchanged.

## Godot Runtime status
**PASS** — implementation commit `c3f972ba2039c3ac1a78ad432414724d214e66b0`. Godot Runtime run [38121039084](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38121039084) completed successfully; the log includes `PASS res://combat/test_bounty_settlement_retry_button.gd` and `RUNTIME_SUITE_PASS tests=48`.

## Known issues
- The UI click regression uses a deterministic test double for the settlement service boundary. The real service's rollback / save semantics remain covered separately by `combat/test_bounty_reward_service_atomicity.gd`.
- No local Godot runtime is available through this GitHub-only workflow; CI is the authority.
- Web Demo was not triggered for this feature branch: `.github/workflows/web-demo.yml` runs on pushes to `main` or manual dispatch only. No web export/deploy pass is claimed for this PR.

## Next step
The exact implementation commit passed Godot Runtime. Make the PR ready for review after the latest documentation commit's Runtime check; Web Demo validation remains tied to main/manual workflow dispatch.

## Handoff point
Keep the UI responsible only for retry presentation/orchestration. Do not move transaction logic out of `BountyRewardService`.
