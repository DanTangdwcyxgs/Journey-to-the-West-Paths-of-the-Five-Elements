# 2026-10-12 · Agent Handoff: Yellow Wind Ridge Stage and Save/Resume Audit

## Goal
Give the next AI/Agent an unambiguous, repository-visible next task and a testable completion checklist.

## Current state
- PR #25 is open and not merged: [separate optional Yellow Fang bounty from the mainline Yellow Wind King](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/pull/25).
- At the time this note was written, implementation head `c180b4351dd4c474209984d3323b1e3a01aed1ab` passed Runtime run [38193241086](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38193241086), with `RUNTIME_SUITE_PASS tests=49`.
- This is the pre-documentation-update SHA. The documentation commit itself must receive its own exact-head CI check.

## What the next Agent should do
1. Work from the PR #25 branch, not main, and do not merge the PR.
2. Read `DEVELOPMENT_RULES.md`, `docs/AI_MEMORY.md`, the development-log index and latest log before changing code.
3. Audit `YellowWindRidgeManager`, Ridge/Cave production screens, stage JSON, NarrativeManager persistence and the existing progression/roundtrip tests.
4. Verify stage unlock and selection, gate milestone, normal encounter return room, mainline boss completion, save-failure rollback, and save/reload recovery. Include a fixture where the optional Yellow Fang bounty was defeated first.
5. Add or extend production SceneTree regression for the complete Ridge → Cave → normal battle → boss battle → Ridge → save/reload path. Only change production code when a reproducible defect is demonstrated.
6. Preserve separation between `BOUNTY_YELLOW_FANG` (optional Yellow Fang) and `YELLOW_WIND_KING` (mainline Yellow Wind King). Do not advance Shared chapters or global chronology for this optional arc.
7. Check CI for the exact new SHA and update this log, index, AI_MEMORY Round and AI_HANDOFF together.

## Systems and files to inspect
- `scripts/world/yellow_wind_ridge_manager.gd`
- `data/world/yellow_wind_ridge.json`
- `ui/yellow_wind_ridge.gd`, `ui/yellow_wind_cave.gd`
- `scripts/world/test_yellow_wind_ridge.gd`
- `scripts/world/test_yellow_wind_cave_progress.gd`
- `combat/test_yellow_wind_ridge_cave_progression.gd`
- `combat/test_yellow_wind_cave_battle_roundtrip.gd`
- NarrativeManager save/load and snapshot/restore implementation

## Guardrails
- No PR merge without explicit user permission.
- No unrelated Camp/Relationship work or general handoff refactor in this batch.
- Do not claim manual review is equivalent to Runtime validation.
- If the audit finds no reproducible bug, record what was actually inspected and which gaps remain rather than manufacturing a code change.

## Completion criteria
- Optional bounty and mainline boss IDs, journal records and gate completion remain independent.
- Stage/gate/room state is consistent after victory, failed save, scene transition and reload.
- Production regression covers the verified boundaries and exact-head Runtime CI has a recorded result.
- Development log, index, AI_MEMORY and AI_HANDOFF agree.
