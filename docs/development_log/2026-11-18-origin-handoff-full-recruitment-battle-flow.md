# 2026-11-18 — Later-Origin Full Recruitment, Battle, and WorldMap Flow

## Goal

Close the production SceneTree coverage gap for Longma-, Bajie-, and Wujing-origin saves. The previous handoff smoke stopped after the first Shared MOVE; separate tests covered recruitment battles and WorldMap controls, but did not prove those pieces worked as one continuous later-origin save flow.

## What changed

Extended `combat/test_origin_shared_handoff_scene_smoke.gd` for all three later-start routes:

1. Complete the selected Origin route, persist its canonical handoff, and resume through the production MainMenu Continue control.
2. Enter the expected Shared EventSequence from the real Journey Continue button, and commit its canonical story MOVE.
3. Verify story location, visited-node fact, current Shared chapter, save/reload, and the appropriate pre-recruitment WorldMap gate.
4. Select the canonical recruitment choice in the production Journey UI and transition to the real BattleUI with the expected Shared encounter ID.
5. Verify the active battle handoff retains source chapter, encounter, and EventSession resume state.
6. Trigger the production victory callback and verify the atomic battle commit advances the expected chapter, timeline, and roster exactly once while preserving the story-established location.
7. Attempt a second stale settlement through BattleResolutionService and assert it is rejected without mutating the serialized NarrativeState (including rewards, roster, chapter, or timeline).
8. Return through the production “继续旅途” control, resume the post-battle EventSession, drive it through END, and verify resume files are cleaned and the save remains consistent.
9. Open the production WorldMap UI, travel through its real node list/button controls, and verify optional travel persists location without changing the chapter pointer, global timeline, or roster.

Also fixed a real Journey UI choice-flow defect in `ui/journey.gd`: when a Shared chapter has a registered EventSequence, the old renderer first demanded the legacy SharedEvent choice, then the sequence presented the same choice node again. The second presentation could be rejected because the choice had already been recorded. The renderer now lets the production EventSequence own its CHOICE nodes and enables Continue to start that sequence. The expanded smoke now enters from the real Continue control, so it protects this behavior.

## Canonical progression and map gates

The test deliberately does not inject future milestones or timeline values:

- **Longma:** recruitment settles at T110. Black Wind North Path (T120) remains locked. The player runs the real Shared-04 EventSequence; its canonical MOVE takes the party to Black Wind North Path and END advances the chapter/timeline to T120. The production map then allows travel along the connected route back to Eagle Sorrow.
- **Bajie:** recruitment settles at T130. The connected Black Wind North Path at T120 is already reachable from Gaojiazhuang, so the production map can travel there without changing chronology.
- **Wujing:** recruitment settles at T150. Dragon Bone Sanctum (T170) remains locked. The player completes the real Shared-08 Party Full EventSequence choice and END, then Shared-09's EventSequence and END, advancing the timeline to T170. The production map then allows travel from Flowing Sands to Dragon Bone Sanctum.

This preserves the WorldMap manager's three real gates: global timeline, required milestones, and graph connection.

## Files changed

- `ui/journey.gd`
- `combat/test_origin_shared_handoff_scene_smoke.gd`
- `docs/development_log/2026-11-18-origin-handoff-full-recruitment-battle-flow.md` (this file)
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation

- Implementation/test head: `608e8afa81df32adf24cbe61763ae9b4c9ea1d8b`.
- Exact-SHA Godot Runtime run [44265989517](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44265989517): **PASS**.
- Run log explicitly reports `PASS res://combat/test_origin_shared_handoff_scene_smoke.gd` and `RUNTIME_SUITE_PASS tests=54`.
- Earlier intermediate runs failed while the test exposed incorrect assumptions about Shared-04 progression and duplicate EventSequence choices. Those are historical diagnostics, not current failures; the final implementation/test SHA above passed.

The later log/index/memory/handoff documentation commits move the branch head; verify the exact final documentation head's Godot Runtime before reporting the branch green.

## Constraints / not claimed

- PR #34 remains Draft/open/unmerged. Main was not changed.
- No merge, release, Web Demo build, Pages deployment, or player-facing screenshot acceptance was performed.
- No image-generation call was made; no art quota, art asset, or art acceptance state was changed.
- SceneTree tests preserve and restore the user's existing narrative save, active encounter state, and pending resume file.

## Next

Review the first complete playable Vertical Slice from a player-facing perspective: route onboarding, chapter pacing, optional exploration clarity, battle preparation/recovery, and save/reload continuity. Convert findings into a small prioritized backlog before expanding content or generating more assets. Do not add historical map visits, future timeline values, or rewards merely to make a route test pass.
