# 2026-10-11 · Atomic Bounty Settlement and Retry

## Goal
Commit a bounty's post-combat inventory, reward, defeated-target journal, and BountyManager status exactly once, and ensure failed saves restore both authoritative narrative state and the local bounty state so the player can retry settlement.

## Starting point
- The cave normal encounter and Yellow Wind King roundtrip passed on exact commit `a552810c769bb2d0725a0edd4fade92a5386c2f0`: Runtime [38120481337](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481337) passed 46/46 and Web Demo [38120481282](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120481282) build/deploy passed.
- Audit found `BountyRewardService.resolve_defeat()` mutates BountyManager status and NarrativeState, then ignores the save return value. BattleUI then saves again after the service returns. This splits one logical victory into two writes with no coordinated rollback.
- BattleUI previously wrote the post-combat inventory into NarrativeState before asking the service to settle the bounty, so the service had no way to snapshot the exact pre-settlement state.

## What changed
- `BountyRewardService.resolve_defeat()` now accepts an optional `inventory_after_battle` payload and snapshots NarrativeState + BountyManager before mutation.
- Final combat inventory, bounty defeat status, victory rewards, world effects, and defeated-target journal are applied within one transaction. If validation/application/save fails, the service restores both snapshots and returns an empty result.
- Successful service settlement owns the single save boundary; BattleUI no longer performs the duplicate save or tries to complete a Ridge stage using the cave room ID.
- On settlement save failure, BattleUI unlocks the result handler and changes the return control to “重试结算”. Clicking it invokes the production settlement handler again on the already-finished battle, without replaying the encounter; it only clears the handoff and marks the result resolved after the commit succeeds.
- Added `combat/test_bounty_reward_service_atomicity.gd` to verify failed save rollback of NarrativeState, inventory, journal and local bounty status, plus successful retry and chronology preservation.

## Why
A bounty victory is a single player-facing event. It must not record a defeated boss without granting rewards, grant rewards without recording the defeat, or leave the local bounty marked defeated when the save did not commit.

## Systems affected
- BountyRewardService
- BattleUI post-victory bounty settlement and retry
- NarrativeState inventory / battle journal
- BountyManager state
- Godot Runtime regression suite

## Files
- `scripts/world/bounty_reward_service.gd`
- `ui/battle_ui.gd`
- `combat/test_bounty_reward_service_atomicity.gd`
- `tests/runtime_suite.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-yellow-wind-cave-battle-roundtrip.md`
- `docs/development_log/2026-10-11-bounty-settlement-atomic-retry.md`

## Tests
- Runtime suite expected entries: 47.
- Forced save failure must return an empty result, restore the exact serialized NarrativeState, and restore BountyManager status to its prior value.
- Successful retry should write exactly one additional save, grant rewards from the final post-combat inventory, mark the bounty defeated, record its journal target, and preserve Shared chapter / global timeline.

## Godot Runtime status
**PASS** — exact implementation commit `3fd65d9f16453b6cb104ca249b4a87859e47895c`. Godot Runtime run [38120711220](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711220) passed with `PASS res://combat/test_bounty_reward_service_atomicity.gd` and `RUNTIME_SUITE_PASS tests=47`; Web Demo run [38120711189](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711189) completed successfully with build and deploy jobs both passing.

## Known issues
- The test injects the save result rather than simulating mid-write filesystem failure.
- The runtime transaction commits NarrativeState and BountyManager in memory together, but BountyManager statuses are currently reconstructed from journal/save-level context rather than directly serialized into NarrativeState.

## Next step
Add a production BattleUI regression for the settlement retry button; then return to side-route pacing and presentation.

## Handoff point
Bounty victory is now the atomic transaction boundary. Keep reward, journal, inventory and local bounty status synchronized and allow settlement retry without repeating combat.
