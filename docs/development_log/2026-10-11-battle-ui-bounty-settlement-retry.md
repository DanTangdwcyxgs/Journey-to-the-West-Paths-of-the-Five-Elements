# 2026-10-11 · Production BattleUI Bounty Settlement Retry

## Goal
Verify the player's actual BattleUI “重试结算” control after an atomic bounty save failure, including rollback, successful retry, no combat replay, exactly-once rewards/journal, and normal exit from the committed result screen.

## Starting point
- The latest implementation code commit was `3fd65d9f16453b6cb104ca249b4a87859e47895c`; its Godot Runtime run [38120711220](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711220) passed 47 registered tests, and Web Demo [38120711189](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38120711189) build/deploy passed.
- The service atomicity regression proved that `BountyRewardService` rolls back state when saving fails, but no SceneTree test entered the production retry button path.
- The active handoff explicitly called for a BattleUI regression next; this batch leaves combat/domain rules and canonical chronology unchanged.

## What changed
- Added an optional `narrative_manager_override` dependency seam to `BattleUI`, used by both initialization and victory settlement. The default production path still creates a normal `NarrativeManager`; the seam lets the SceneTree test deterministically toggle the persistence result without replacing the battle scene or settlement service.
- Added `combat/test_battle_ui_bounty_settlement_retry.gd`. It instantiates the production `ui/battle_ui.tscn`, uses the actual engine victory signal, forces the first save to fail, then presses the real retry button with saving enabled.
- The regression checks exact NarrativeState/BountyManager rollback, the preserved handoff and visible retry feedback, unchanged enemy/turn state, a successful single retry save, exact post-battle inventory plus one reward grant, one defeated-target journal entry, preserved Shared chapter/timeline, and the normal result-screen exit without a second settlement.
- Registered the SceneTree regression in `tests/runtime_suite.gd`.

## Why
The service-level transaction and the UI retry control form one player-facing recovery path. A service test alone cannot detect a miswired button, an accidental scene exit, an incorrect retry label, or a second settlement triggered when the player leaves the victory summary.

## Systems affected
- BattleUI manager dependency boundary
- Bounty settlement failure/retry presentation
- NarrativeState inventory and battle journal
- BountyManager status
- Godot Runtime suite

## Files
- `ui/battle_ui.gd`
- `combat/test_battle_ui_bounty_settlement_retry.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- Expected registered Runtime suite entries: 48.
- First save failure should leave the battle scene active, restore the narrative and bounty snapshots, preserve the handoff, and expose an enabled “重试结算” control.
- The real retry button should commit one save, grant the 300-coin reward and each bounty item once, record the target once, and preserve the Shared chapter/timeline.
- The ordinary continue action after a successful settlement should leave the battle scene without another save, combat replay, or duplicate reward/journal entry.

## Godot Runtime status
**PENDING** — this new regression must pass on the exact implementation SHA before being marked complete. The previous 47/47 Runtime result validates only the parent code, not this new UI test.

## Web Demo status
**PENDING** — verify build/deploy for the exact implementation SHA. The runtime UI path is exercised by the headless Godot suite; Web Demo also serves as an export/build regression.

## Known issues
- The battle victory itself is driven by the production engine signal rather than manually playing all turns; this test focuses on settlement/retry and scene-boundary behavior, not combat balance.
- BountyManager status is still reconstructed from the battle journal/save context rather than serialized directly into NarrativeState; this batch intentionally does not redesign that compatibility boundary.

## Next step
After exact-SHA Runtime and Web Demo validation, return to the planned vertical-slice experience review: pacing, interactive exploration, and final character PNG/WebP asset review.

## Handoff point
The production BattleUI retry control now has a dedicated SceneTree regression; use its exact Actions status as the gate before extending bounty rewards or adding more dungeon mechanics.
