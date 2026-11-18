# 2026-11-18 — Later-Origin Full Recruitment, Battle, and WorldMap Flow

## Goal

Close the production SceneTree coverage gap for Longma-, Bajie-, and Wujing-origin saves. The previous handoff smoke stopped after the first Shared MOVE; separate tests covered recruitment battles and WorldMap controls, but did not prove those pieces worked as one continuous later-origin save flow.

## What changed

Extended `combat/test_origin_shared_handoff_scene_smoke.gd` for all three later-start routes:

1. Complete the selected Origin route, persist its canonical handoff, and resume through the production MainMenu Continue control.
2. Enter the expected production Shared EventSequence and commit its canonical story MOVE.
3. Verify story location, visited-node fact, current Shared chapter, save/reload, and the appropriate pre-recruitment WorldMap gate.
4. Select the canonical recruitment choice in the production Journey UI and transition to the real BattleUI with the expected Shared encounter ID.
5. Verify the active battle handoff retains source chapter, encounter, and EventSession resume state.
6. Trigger the production victory callback and verify the atomic battle commit advances the expected chapter, timeline, and roster exactly once while preserving the story-established location.
7. Attempt a second stale settlement through BattleResolutionService and assert it is rejected without mutating the serialized NarrativeState (including rewards, roster, chapter, or timeline).
8. Return through the production “继续旅途” control, resume the post-battle EventSession, drive it through END, and verify resume files are cleaned and the save remains consistent.
9. Open the production WorldMap UI, travel through its real node list/button controls, and verify that optional travel persists location without changing the chapter pointer, global timeline, or roster.

## Canonical progression and map gates

The test deliberately does not inject future milestones or timeline values:

- Longma: recruitment settles at T110. Black Wind North Path (T120) remains locked until the real non-combat Shared-04 step is completed through Journey, which advances the save to T120. The map then allows travel from Eagle Sorrow to the connected North Path.
- Bajie: recruitment settles at T130. The connected Black Wind North Path at T120 is already reachable from Gaojiazhuang, so the test travels there without changing chronology.
- Wujing: recruitment settles at T150. Dragon Bone Sanctum (T170) remains locked until the real Party Full choice and Shared-08 / Shared-09 progression are completed through Journey, advancing the timeline to T170. The map then allows travel from Flowing Sands to Dragon Bone Sanctum.

This preserves the world-map manager's three real gates: global timeline, required milestones, and graph connection.

## Files changed

- `combat/test_origin_shared_handoff_scene_smoke.gd`
- `docs/development_log/2026-11-18-origin-handoff-full-recruitment-battle-flow.md` (this file)
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation

- Implementation/test commit: `c9b3a3a6855e4d429df22398e88f790152fa066d`.
- Exact-SHA Godot Runtime run: [44264826975](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44264826975).
- Validation status at the time this log was first authored: pending; do not treat the test as passed until the run completes successfully and the log confirms `ORIGIN_SHARED_HANDOFF_FULL_FLOW_PASS cases=3` plus `RUNTIME_SUITE_PASS tests=54`.
- The log/index/memory/handoff documentation commits also move the branch head; verify the final exact documentation head's Godot Runtime before reporting the branch green.

## Constraints / not claimed

- PR #34 remains Draft/open/unmerged. Main was not changed.
- No merge, release, Web Demo build, Pages deployment, or player-facing screenshot acceptance was performed.
- No image-generation call was made; no art quota, art asset, or art acceptance state was changed.
- SceneTree tests preserve and restore the user's existing narrative save, active encounter state, and pending resume file.

## Next

After exact-head validation, review any remaining player-facing gameplay or pacing gaps in the first complete Vertical Slice. Do not add historical map visits, future timeline values, or rewards just to make a route test pass.
