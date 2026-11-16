# 2026-11-16 — Origin Handoff Shared-History Reconciliation

## Goal

Continue PR #34 and verify that all five selectable Origin starts can enter their declared first Shared chapter after the Yellow Wind insertion.

## Findings

Two related progression defects affected later-start campaigns:

1. NarrativeManager.handoff_origin_to_shared() set the route's current Shared chapter and roster, but did not record earlier Shared chapters as historical facts. ChapterRuntime.can_enter() therefore rejected valid handoff points for Longma (Shared-03), Bajie (Shared-05), and Wujing (Shared-07). Wujing's handoff also crossed the newly inserted Yellow Wind chapter without recording it as completed.
2. SharedJourneyManager._apply_recruitment_events() treated an already-recruited character as a failed recruitment. Later-start campaigns already contain Longma, Bajie, or Wujing in their reconciled roster, so the corresponding canonical Shared recruitment chapter could fail during settlement.

## Changes

- Origin handoff now verifies that its target exists in the registered Shared chapter catalog before mutating state.
- Origin handoff reconciles all Shared chapters strictly before the target as historical facts: completed chapter IDs, chronology milestones, battle milestones, world-effect milestones/effects, and any declared legacy boss defeat ID.
- The target Shared chapter remains current and uncompleted. Reconciliation does not replay prior scenes or grant historical chapter rewards.
- Shared recruitment events are now idempotent when their character is already present in recruited_characters. They preserve the roster and still make the chapter's Memory entries available.
- Extended combat/test_origin_shared_handoff.gd to validate prior Shared history, target entry gates, historical boss/world-effect facts, and successful completion of the Longma, Bajie, and Wujing recruitment chapters without duplicate recruitment.

## Files Changed

- scripts/narrative/narrative_manager.gd
- scripts/narrative/shared_journey_manager.gd
- combat/test_origin_shared_handoff.gd

## Validation

- PASS: exact PR head 5ed4fac2a1fe2aaf736a52dd6227f1aab2110229.
- Godot Runtime run [43796084337](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/43796084337) completed successfully on that exact SHA.
- The log explicitly reports PASS res://combat/test_origin_shared_handoff.gd and RUNTIME_SUITE_PASS tests=53.
- The full registered Runtime suite passed 53/53. Earlier historical PR #34 failures remain diagnostics and are not counted as current validation.
- No Web Demo build, Pages deployment, or merge was performed. PR #34 remains Draft/open and main is unchanged.

## Art Slot / Quota Record

- The America/Los_Angeles 2026-11-16 production schedule selects Sha Wujing's four-view turnaround sheet.
- Required runtime crop: transparent pixel-art PNG at 128×192; source sheet: one transparent 2×2 turnaround with the same model, costume, pose, and crescent-moon spade grip across front 3/4, right profile, rear 3/4, and left profile.
- Acceptance remains governed by docs/visual_reference/AI_ART_PRODUCTION_SCHEDULE.md, ART_REVIEW_STANDARD.md, and the Sha Wujing brief in prompts/MASTER_ASSET_PROMPT_LIBRARY.md.
- No image-generation call was made in this session because an image-generation tool was not available. Do not mark the daily quota as consumed or the Wujing slot as generated; its status remains Pending. Do not add an unreviewed image to the repository.

## Known Limitations / Next Steps

1. Add a production SceneTree smoke for Longma-, Bajie-, and Wujing-origin handoffs through MainMenu → Journey → current Shared sequence, including the actual WorldMap landing and the first post-handoff player action.
2. Review whether historical handoff state should also seed any location-specific discovery data; do not invent map visits beyond what the route narrative establishes.
3. When image generation is available and today's quota is confirmed unused, attempt the scheduled Sha Wujing turnaround using the canonical prompt. Reject the result unless all four views, silhouette, spade, transparent background, and crisp pixel clusters pass review. Only then archive/crop the source and run the art tooling tests.
4. Keep PR #34 Draft/open. After owner review/approval and merge, run the merged-main Godot Runtime and Web Demo build/export/Pages deployment against the exact merged SHA. No deployment is claimed before that point.

## Handoff

Start with this log, then read the latest AI_HANDOFF.md section and docs/AI_MEMORY.md Round 78. The initial fix/test head was 5ed4fac2a1fe2aaf736a52dd6227f1aab2110229; the latest expanded production-scene test head is 13649fc3c1224892bfc3858839ca66467bbad645 on feature/shared-yellow-wind-mainline-2026-11-13.

## Follow-up — Roster Milestones and Production SceneTree Validation

Static route checks exposed one more convergence requirement: the handoff milestone for the starting character was not enough to describe all previously recruited companions. Map nodes use the canonical recruitment milestones as gates, so later-start campaigns also need the milestone facts for earlier members of their reconciled roster.

- Origin handoff now records the canonical recruitment milestone for every reconciled roster member: Wukong, Longma, Bajie, and Wujing. The milestone timeline uses that character's canonical handoff point and remains monotonic.
- Added combat/test_origin_shared_handoff_scene_smoke.gd and registered it in tests/runtime_suite.gd.
- The production SceneTree test runs Longma, Bajie, and Wujing cases through a saved Origin handoff → MainMenu Continue → production Journey → the current Shared EventSequence → its first MOVE. It verifies the correct marker, visited-node record, save/reload, unchanged current Shared chapter, and the route-appropriate next WorldMap gate.
- The static all-route regression additionally verifies the Wukong/Longma/Bajie/Wujing recruitment milestones and checks map reachability for the corresponding route stage.

### Exact-head validation

- PASS: exact implementation/test head 13649fc3c1224892bfc3858839ca66467bbad645.
- Godot Runtime run [43797252773](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/43797252773) succeeded.
- The log explicitly reports PASS res://combat/test_origin_shared_handoff.gd, PASS res://combat/test_origin_shared_handoff_scene_smoke.gd, and RUNTIME_SUITE_PASS tests=54.
- This validates the first production Shared MOVE and route-appropriate WorldMap gate, not the entire recruitment battle / after-battle dialogue / END / manual WorldMap UI flow. That remains the next test expansion.
- PR #34 remains Draft/open; main is unchanged. No Web Demo build, Pages deployment, or merge was performed.

### Art status

- The 2026-11-16 Sha Wujing turnaround remains Pending. No image-generation call was made because no image-generation tool was available in this session; the daily generation quota is not marked consumed. No image was added.

### Next

1. Extend the three later-start SceneTree cases through recruitment choice, production BattleUI victory, atomic chapter settlement, resumed after-battle dialogue, and END; then open the real WorldMap UI and inspect the next connected travel node.
2. Keep prior-history reconciliation limited to explicit canonical chapters, milestones, world effects, and boss facts. Do not invent historic map visits or grant prior chapter rewards.
3. When the generator is available and the local-day quota is confirmed unused, attempt the scheduled Sha Wujing 2×2 turnaround with the canonical master brief; accept only after the full art review and exact crop contract.
4. After owner-approved merge, run Godot Runtime and Web Demo export/Pages deployment on the exact merged main SHA.
