# 2026-11-13 — Shared Yellow Wind Mainline Integration

## Objective

Integrate the existing Yellow Wind Ridge / Yellow Wind Cave / Yellow Wind King vertical slice into the canonical shared Journey between Gaojiazhuang and Flowing Sands.

## Implementation

- Added `SHARED-06A-YELLOW-WIND` at T145 after `SHARED-06-FOUR-PERSON-JOURNEY` and before `SHARED-07-FLOWING-SANDS`.
- Declared the expedition destination at `BLACK_WIND_NORTH_PATH`; Journey hands off to the existing WorldMap and Yellow Wind Ridge entry.
- Reused the existing Ridge stages, cave rooms, normal encounter and Yellow Wind King boss. The mainline King now uses a Shared battle handoff.
- Reused the atomic `BattleResolutionService` boundary for inventory rewards, journal entry, shared battle milestone, chapter completion, T145 advancement and next-chapter pointer. Save failure restores the entire narrative state.
- Kept `BOUNTY_YELLOW_FANG` independent of `YELLOW_WIND_KING`.
- Added legacy-save reconciliation for an existing Yellow Wind King victory without the new Shared battle milestone; this backfills progress but grants no rewards again.
- Made Flowing Sands require Yellow Wind as its direct chapter prerequisite.

## Regression work

- Added `combat/test_shared_yellow_wind_chapter.gd` for canonical order, T145, expedition location, pre-boss lock, Flowing Sands lock and legacy-save no-duplicate-reward behavior.
- Updated the Shared battle scene-transition and battle-journey bridge fixtures so their Flowing Sands case completes Yellow Wind before entering Shared-07.
- Updated the boss settlement retry fixture to use the actual recruited roster without synthetic Longma/Bajie milestone labels.
- Corrected the Ridge availability gate to read `NarrativeState.recruited_characters`. Recruitment world-effect labels are not guaranteed to be copied to `completed_milestones` for all start routes.
- The retry smoke now snapshots battle context before scene transition and avoids dereferencing a freed BattleUI object when collecting diagnostics.

## Validation history

- [43358438779](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/43358438779): failed on an omitted Journey handler colon; corrected.
- [43358645955](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/43358645955): most new Yellow Wind tests passed, but the settlement retry did not return to the Cave.
- [43360259927](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/43360259927): failed the Shared-07 scene-transition fixture because it skipped the newly inserted trial, and the retry test's debug statement accessed a freed BattleUI.
- **Godot Runtime for the current follow-up commit is pending.** No Runtime pass or Web Demo/deployment is claimed.
- PR #34 remains Draft/open and unmerged.

## Next step

Run Godot Runtime on the exact latest SHA. Inspect all failures from that SHA, fix the production or fixture issue, and only then record a green Runtime result in this log, `docs/AI_MEMORY.md`, and `AI_HANDOFF.md`.
