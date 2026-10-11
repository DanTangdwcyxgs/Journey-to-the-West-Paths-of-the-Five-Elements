# 2026-10-11 · Wukong → Longma Memory Vertical Slice

## Goal
Connect the last Wukong Origin chapter, the canonical shared pilgrimage opening, Longma's recruitment, and an actual read-only Longma memory playback on one persisted production UI flow.

## Starting point
- The Shared-01 → Shared-04 smoke used to seed a completed Wukong route and call `handoff_origin_to_shared()` directly. Production WUK-15 END was only exercised by a separate smoke.
- The same Shared smoke asserted that Longma memories were unlocked after recruitment, but did not play one during that contiguous save.

## What changed
- Reworked `combat/test_shared_opening_to_black_wind_smoke.gd` to seed canonical WUK-01..14 completion while leaving WUK-15 current.
- Enters via production MainMenu Continue, plays the real `WUK-15-SEQUENCE` through Journey's UI path, verifies the route handoff saves Shared-01 / WUKONG_RECRUITED / canonical starting roster, then continues the same journey through Shared-01, Shared-02, Shared-03 recruitment battle and Shared-04.
- After Shared-03 actually recruits Longma and unlocks LONGMA-01/02, the smoke selects `回忆 · LONGMA-02` in the production Journey sidebar, presses the real memory button, reads the two canonical dialogue entries via the typewriter control, explicitly completes the memory and reloads the save.
- Verifies memory replay does not run its historical battle node, create battle handoff/resume data, or alter Shared chapter/timeline/recruited roster/current location. Only the available/played Memory flags may change.
- Continues into Shared-04 after playback, moves to Black Wind North Path, and retains the existing final progression/save assertions.

## Why
Testing route handoff, Longma battle, and Memory independently did not prove the player's central opening fantasy in one saved journey. The integrated sequence now protects that actual vertical-slice boundary.

## Systems affected
- WUK-15 Origin finalization and Origin → Shared handoff
- Shared-01 / Shared-02 story choices and Story MOVE
- Shared-03 Longma recruitment / battle resume
- Read-only Longma Memory playback and save/load
- Shared-04 WorldMap arrival

## Files
- `combat/test_shared_opening_to_black_wind_smoke.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-single-save-shared-opening-black-wind.md`
- `docs/development_log/2026-10-11-wukong-longma-memory-vertical-slice.md`

## Tests
- Extends the existing SceneTree entry; expected Runtime suite count remains 44.
- WUK-15 END → Shared-01 must save and reload, then the same production Journey must complete Shared-01..04.
- Longma Memory must be unlocked by the real Shared-03 victory, played through production Journey controls, completed explicitly and persisted before Shared-04 continues.
- The final save must be Shared-05, WorldMap current location BLACK_WIND_NORTH_PATH, Wukong route complete, Longma recruited, and LONGMA-02 recorded as played rather than available.

## Godot Runtime status
**PENDING** — validate this exact implementation SHA via Godot Runtime and Web Demo. Prior independent smokes do not prove the integrated path.

## Known issues
- WUK-01..14 progress is seeded by canonical chapter progression services rather than replayed through every Origin UI scene. WUK-15 runs via production UI; the battle victory is still shortcut by the production success callback rather than a full player-turn simulation.
- Memory is still textual dialogue playback; historical choices, combat simulation, sprites and voice performance are intentionally omitted from the read-only session.
- Final polished character art / environment art remains separate product work.

## Next step
Once both CI workflows pass, perform a pacing and usability review of this first vertical slice, prioritizing interactive exploration/region presentation and final production assets over further framework-only changes.

## Handoff point
Integrated WUK-15 → Shared-01..04 → Longma Memory slice. Preserve the one canon timeline and ensure Memory changes only its own played/available flags.
