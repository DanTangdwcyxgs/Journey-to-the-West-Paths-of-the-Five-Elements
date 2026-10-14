# 2026-10-14 · Region Entry Requirement Feedback

## Goal
Make locked optional regions understandable from WorldMap: when a region is not yet available, tell the player which story milestone or timeline threshold is missing instead of displaying only a disabled entry button. Keep the gate rule centralized and preserve canon.

## Starting point
- PR #29 adds the third data-driven region, Black Wind North Path, and extends the production SceneTree smoke. Its exact implementation head and previous docs-sync head both passed Runtime at 52/52.
- `RegionExplorationManager.can_enter()` previously returned only a boolean. WorldMap disabled the region button without explaining the missing condition.
- Region eligibility is based on current location, global timeline, and required milestones, all declared in the region catalog.

## Changes
- Added `RegionExplorationManager.get_entry_block_reason()`. It returns an empty string when allowed, otherwise a player-facing Chinese explanation for location, timeline, or recruitment/milestone requirements.
- Refactored `can_enter()` to delegate to that method, keeping the eligibility decision and explanation on one code path.
- Added friendly milestone labels for the five canonical party/recruitment milestones rather than exposing internal IDs.
- Added an inline WorldMap hint below the region button plus a tooltip. Available regions explain that exploration is optional and does not advance the main story; locked regions explain how to unlock them.
- Extended `combat/test_region_exploration.gd` with direct gate-contract assertions and production WorldMap checks for timeline/milestone hint text, disabled state, and re-enabling when the required state is restored.

## Files changed
- `scripts/world/region_exploration_manager.gd`
- `ui/world_map.gd`
- `combat/test_region_exploration.gd`
- `docs/architecture.md`
- `docs/development_log/2026-10-14-region-entry-feedback.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Test coverage
- Region reason is empty exactly when `can_enter()` is true.
- Timeline-locked region feedback includes the required and current timeline.
- Missing recruitment milestone feedback is translated into player-facing wording.
- Production WorldMap shows feedback for a locked region and re-enables the action after restoring eligibility.
- Existing region exploration checks continue to guard persistence, save rollback, and the fixed Journey chronology.

## Validation
- Feature implementation/test head: `e50f7089ce18c598f513643149cd31a20eff56e3`.
- Exact-head Godot Runtime was queued/in progress when this log was written. Do not claim this iteration passes until a completed run for the code head or newer documented head reports `RUNTIME_SUITE_PASS tests=52`.
- The branch is still part of PR #29. No main-branch merge, image generation, Web Demo deployment, or screenshot acceptance is claimed.

## Known limitations
- Tooltip visibility varies by platform; the inline label is the primary player-facing explanation.
- Region exploration remains clue-only and does not award items or progress story flags.

## Next step / Agent handoff
1. Inspect CI for the current branch head; if the test fails, fix the root cause and rerun exact-head Runtime.
2. After the code and documentation sync pass, inspect the Web Demo path only if a demo build/deploy is explicitly run.
3. Keep PR #29 open unless the user explicitly authorizes merge. Continue with non-art gameplay polish or the outstanding visual review once this gate-feedback change is validated.
