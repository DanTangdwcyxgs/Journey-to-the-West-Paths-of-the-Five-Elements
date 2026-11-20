# 2026-11-19 — Player-Facing Vertical Slice Audit

## Goal

Review the first playable slice from a player's perspective without consuming image-generation quota. Look beyond manager-level state tests and identify friction in onboarding, narrative choices, battle recovery, map navigation, and save continuity.

## Audit scope and findings

### Main menu / save safety — fixed

- The MainMenu previously enabled Continue from file existence alone, but did not load the NarrativeState before drawing the save preview. An existing slot could therefore still show “尚未开始旅程”.
- New Game wrote to the single narrative slot without an explicit overwrite confirmation.
- `ui/main_menu.gd` now loads the existing save in `_ready()`, displays the real protagonist / global timeline / Shared chapter / roster, enables Continue only for a readable save, and identifies the protagonist on the Continue button.
- Starting a new route with an existing slot now opens a confirmation that explains the single-slot overwrite. Cancel preserves the existing save; confirmation is the only path that starts and saves the replacement route.
- Added `combat/test_main_menu_save_safety.gd` and registered it in `tests/runtime_suite.gd`. It drives the production MainMenu and Journey scenes, verifies the save preview, verifies Cancel preserves the previous save, and verifies explicit confirmation replaces it with the selected route.
- PASS: exact implementation/test SHA `df8119cf5c74d2bafda95089cc4e88e6208a48a9`, Godot Runtime run [44438467442](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44438467442), `RUNTIME_SUITE_PASS tests=55`; log contains `PASS res://combat/test_main_menu_save_safety.gd`.

### EventSequence choice ownership — fixed for Shared and Origin

- The Shared Journey renderer and the Origin route renderer both had a legacy-choice presentation path. When a chapter already had a production EventSequence containing a CHOICE node, the UI could commit the same choice before the EventRunner reached it. The EventRunner would then reject the sequence's CHOICE because EventRuntime correctly prevents a choice from being applied twice.
- `ui/journey.gd` now detects the presence of the registered `<chapter>-SEQUENCE` and lets that EventSequence own its CHOICE nodes. The legacy choice renderer is only used for chapters without a registered sequence.
- Added `combat/test_origin_sequence_choice_ui_smoke.gd`, registered in Runtime. It loads a saved Tang TANG-04 state through MainMenu Continue, confirms the legacy choice does not appear first, starts the real sequence, submits the EventRunner choice once, reaches END, and verifies the route cursor advances exactly once.
- PASS: exact implementation/test SHA `601036cda520680fa0e5f2256090c3408d486af4`, Godot Runtime run [44438943432](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44438943432), `RUNTIME_SUITE_PASS tests=56`; log contains `PASS res://combat/test_origin_sequence_choice_ui_smoke.gd` and `PASS res://combat/test_main_menu_save_safety.gd`.
- Route data audit: the five Origin routes contain 46 chapters in total (Wukong 15, Tang 8, Longma 6, Bajie 9, Wujing 8). Their chapter IDs are represented by registered EventSequences across `data/narrative/event_sequences.json` and `data/narrative/event_sequences_origin.json`; no Origin chapter was missing sequence coverage in this check.

### Narrative battle defeat / retry — implementation added; full integration validation pending

- The previous defeat path displayed failure feedback but did not preserve a retryable EventSequence battle node. The narrative handoff was either cleared or restored by the generic battle-resume factory, which always interpreted a pending BATTLE as a victory and advanced to its next node. Because the player's CHOICE is intentionally persisted before the encounter, restarting the sequence from its beginning is not a safe retry path either.
- `NarrativeEventSession.resume_from_battle_record()` now accepts an explicit `resolve_pending_battle` parameter (default true to preserve existing victory-resume behavior). Defeat recovery can restore the runner without resolving the BATTLE node.
- `BountyEncounterState.mark_battle_failed()` persists a `battle_failed` marker alongside the active EventSession snapshot.
- `NarrativeBattleUI` marks a failed narrative battle before allowing return. If saving the retry marker fails, the Return action is disabled and the player is told to remain on the battle screen so the only retry context is not discarded.
- `JourneyScreen._restore_event_session()` detects a failed record and restores the pending BATTLE node without treating it as victory. It re-persists the failed retry snapshot in the active handoff so quitting before retry does not lose the selected choice or pending encounter.
- A new battle retry smoke, `combat/test_origin_battle_defeat_retry_roundtrip.gd`, has been added and registered in `tests/runtime_suite.gd`. It exercises Longma's production LONGMA-02 choice → BATTLE → defeat → Journey return → exact BATTLE-node restoration → same encounter retry → real victory settlement → post-battle dialogue → END, while backing up and restoring the user's save and handoff files. The harness centralizes cleanup in `_initialize()` so early exits still restore user files, and includes a 45-second watchdog that reports the last stage if the test ever stops making progress.
- Handoff migration was also hardened in `BountyEncounterState.clear()`: it closes the read file and only deletes the active handoff after a pending EventSession was successfully written to RESUME_PATH. If reading or migrating fails, the active file is retained. `get_active_record()` now closes its read handle and only consumes a valid pending resume record.
- Current implementation commits at time of this log:
  - `cb61627dfc15c6bdc52ea023259c1f47260bf634` — optional failed/victory resume behavior.
  - `fcfa64982eeeecb3a64acb51f78feec9467fa989` — persist battle_failed marker.
  - `e99ccacac747f357096ca778396fc321020c5520` — production defeat feedback / handoff marking.
  - `2297110ec51275ff47c5bdac172fc57af20b9785` — restore failed battle at pending BATTLE node.
  - `734e1057b1d4b9773227a28f3e27cab90cb86e4c` — initial full retry smoke; its first version exposed a missing test helper and was not registered in Runtime at that SHA.
  - `0df3dd7d5679413746a8d36fb89db3d783278a5e` — register retry smoke; first run exposed the missing helper.
  - `5464ed4347f62ee78000a5dd538dc4c391e85f78` — fix the smoke's assertion helper and await its cleanup.
  - `db57f9c49d31ef513f952439caf794e448fdc099` — harden handoff migration so failed resume writes do not discard the active retry record.
- PASS: full defeat/retry integration implementation and test SHA `dccd461c9cb429335918a9ff9a6cac5cfca3c7ac`, Godot Runtime run [44441574795](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44441574795). The job log explicitly contains `PASS res://combat/test_origin_battle_defeat_retry_roundtrip.gd` and `RUNTIME_SUITE_PASS tests=57`.
- PASS: watchdog / diagnostic-stage harness SHA `63a65218dc9e5e4d268acc42ba505cc17ff48cb7`, exact-head Godot Runtime run [44441787645](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44441787645). The job log again contains `PASS res://combat/test_origin_battle_defeat_retry_roundtrip.gd` and `RUNTIME_SUITE_PASS tests=57`. This is the latest validated implementation/test head at the time of this entry.
- Intermediate runs during test-harness development exposed a missing assertion helper and an unhelpful asynchronous cleanup arrangement. Those were corrected; the final test and the watchdog-enabled exact head both pass.

## Existing safeguards confirmed during audit

- Story MOVE save failure restores the complete NarrativeState snapshot, leaves the EventSession on the MOVE action, and exposes a retry: `combat/test_story_move_save_failure_rollback.gd`.
- WorldMap free-travel save failure restores location/history and leaves the same destination retryable: `combat/test_world_map_travel_save_failure_rollback.gd`.
- The WorldMap is a reachable-location list with descriptions and connection text rather than a drawn node map. This is a presentation limitation, not a progression-rule defect.
- Battle UI exposes HP, BP, character-specific resources, shield, statuses, skills, items, and turn number; the audit did not find a first-time tutorial explaining these mechanics.
- MainMenu contains a visible “测试战斗” direct-entry control that opens BattleUI. It is useful during development, but should be gated behind a developer/test option or removed from a public demo after owner decision. This audit did not remove it.
- Preparation, camp, shop, party formation, map, Journey return, and main-menu navigation are present; this pass did not perform visual screenshot acceptance or responsive-layout certification.

## Prioritized player-facing backlog

### P0 — correctness / data safety

- [x] Load and preview the real single-slot save before enabling Continue.
- [x] Confirm destructive New Game overwrite and preserve the old save on cancel.
- [x] Ensure EventSequence-owned CHOICE nodes are not pre-committed by legacy UI.
- [x] Finish exact-head validation for narrative defeat → retry at the same BATTLE node → victory settlement → post-battle END. PASS: battle retry smoke at SHA `63a65218dc9e5e4d268acc42ba505cc17ff48cb7`, Runtime run [44441787645](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44441787645), suite 57/57.
- [x] Add an explicit failure-injection regression proving that a failed migration from active handoff to RESUME_PATH keeps the active retry record intact. A directory at `RESUME_PATH` deterministically forces `FileAccess.open(..., WRITE)` to fail; the regression verifies the active handoff remains byte-for-byte unchanged and restores prior user files. PASS: SHA `f3dca5a98ee72e15b2ca67cfb9a1157b272282c9`, Runtime run [44446160315](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/44446160315), suite 58/58.

### P1 — demo readiness / onboarding

- [ ] Decide whether “测试战斗” is hidden behind a developer-only flag in public builds.
- [ ] Add a short first-battle tutorial for target selection, weakness / shield break, BP / Boost, items, and each character's unique resource.
- [ ] Add a five-route first-session acceptance matrix: New Game, opening sequence, first route choice, first battle, defeat/retry, save/reload, and route convergence. Current tests cover these flows in separate route-specific slices, not as one complete first-session matrix for every start.
- [ ] Consider a backup/export path for the single narrative slot before adding cloud or multiple-slot complexity.

### P2 — exploration / presentation

- [ ] Decide whether to replace or augment the WorldMap reachable-node list with a visual route graph. Preserve existing timeline, milestone, and connection gates.
- [ ] Perform player-resolution screenshots and window-size tests for MainMenu, Journey dialogue/choice, BattleUI, and WorldMap; no visual acceptance was made in this audit.
- [ ] Improve first-time explanation for map rumors, optional bounties, camp rest, preparation, and region exploration without turning optional content into mainline chronology.
- [ ] Revisit chapter summaries and pacing after a complete first-session playtest from each start.

## Constraints / claims

- PR #34 remains Draft/open/unmerged; main is unchanged.
- No Web Demo build, export, deployment, or merge was performed.
- This gameplay branch contains no image binary or art-catalog change. The one 2026-11-19 Wukong generation was handled separately on the art branch; see its handoff and log.
- No historical map visit, reward, or global timeline fact was invented to simplify testing.
- All new SceneTree fixtures preserve and restore user save / encounter / resume files.

## Next

1. Resolve and inspect the two currently pending Runtime jobs; prioritize exact-head validation of `db57f9c49d31ef513f952439caf794e448fdc099`.
2. If the full defeat/retry test fails, use its exact assertion/SceneTree output to correct either the production flow or test driver; do not weaken the assertion that defeat remains at BATTLE and does not advance the chapter.
3. Add a deterministic failed-resume-migration test seam and regression.
4. Walk the first-session matrix route by route; keep debug controls clearly separate from public/demo entry.
5. Keep PR #34 Draft/open and do not merge/deploy without explicit owner approval.
