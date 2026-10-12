# 2026-10-12 · Yellow Wind King Settlement Rollback and Resume Audit

## Goal
Close the remaining save-failure regression gap for the mainline Yellow Wind King after separating it from the optional Yellow Fang bounty.

## Starting point
- Work continues on PR #25 branch `codex/separate-yellow-wind-bounty-from-main-boss-2026-10-12`; do not merge without explicit user permission.
- The production cave roundtrip already checks a previously defeated BOUNTY_YELLOW_FANG does not block the YELLOW_WIND_KING fight, and follows normal encounter → mainline boss → Cave → Ridge with real scene transitions.
- Existing retry coverage exercises the optional bounty ID, while the mainline ID has a different catalog definition and is the authority for completing the Ridge gate. The missing seam is the real BattleUI save-failure/retry path with the mainline target ID and post-save reload.

## What changed
- Added a production BattleUI SceneTree regression for YELLOW_WIND_KING.
- Force the first post-victory save to fail and verify the exact NarrativeState and BountyManager snapshots are restored, the active handoff remains available, the gate stays incomplete, and no mainline defeat entry is written.
- Press the production retry button, then verify the boss is recorded once under YELLOW_WIND_KING while a prior BOUNTY_YELLOW_FANG defeat remains separate.
- Reload through a fresh NarrativeManager and then the production Cave and Ridge scenes; verify the final room cursor, four-of-four stage completion, and unchanged Shared chapter / global timeline / party.

## Why
The mainline and optional targets intentionally share the generic bounty battle settlement service, but they have distinct identities and progression effects. Regression must exercise the mainline identity at the real UI and save boundary so the Ridge gate cannot be completed by a failed write or by the optional bounty.

## Systems affected
- Production BattleUI bounty settlement retry
- Yellow Wind Ridge gate completion state
- NarrativeState journal, inventory and save/load
- Godot Runtime SceneTree suite

## Files
- `combat/test_yellow_wind_king_settlement_retry.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Tests
- The new SceneTree regression uses the production BattleUI scene and its actual combat-finished signal / retry button.
- It pre-defeats the optional Yellow Fang, fails and retries YELLOW_WIND_KING settlement, then reloads the production Cave and Ridge scenes.
- Expected Runtime suite entries: 50.

## Godot Runtime status
PENDING — validate the exact new branch head. The prior branch head is not sufficient evidence for this change.

## Web Demo status
PENDING — check the workflow result for the exact new branch head; the latest implementation-only changes require fresh validation.

## Known issues
- This test drives the production victory callback after setting a deterministic post-combat inventory; it validates settlement boundaries, not battle balance or turn-by-turn combat.
- Final character PNG/WebP assets remain separate art work and are not substituted with placeholder SVGs.

## Next step
After the exact head passes Runtime, recheck the full PR diff and validate the PR head. Do not merge PR #25. Then return to the product-facing vertical-slice audit: Shared-02 → optional exploration → Shared-03 pacing, region entry / interactions, and final character art review.

## Handoff point
Use this regression as the mainline-specific complement to the existing Cave roundtrip and optional bounty retry tests. Preserve the ID boundary: BOUNTY_YELLOW_FANG is optional; YELLOW_WIND_KING alone completes the Yellow Wind Ridge gate. The next agent starts by reading this file and the current exact-head Actions result.
