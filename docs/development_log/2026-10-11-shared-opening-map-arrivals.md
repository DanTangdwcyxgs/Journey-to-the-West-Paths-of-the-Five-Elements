# 2026-10-11 · Shared Opening / Eagle Sorrow Map Arrivals

## Goal
Make the current WorldMap location match the story from Shared Journey's opening through Bai Longma's recruitment.

## Starting point
- Shared-05 / Gaojiazhuang and Shared-07 / Flowing Sands now use canonical MOVE nodes. Their first Runtime attempt exposed a legacy battle-bridge test that assumed dialogue immediately preceded choice.
- Compatibility correction commit `9cd478d516ad4dfaaa749dbf5c017ae210ff17cb` passed Runtime [38117421680](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117421680) (42/42) and Web Demo [38117421677](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117421677) build/deploy.

## What changed
- Added Shared-01 MOVE to `FIVE_ELEMENTS_MOUNTAIN` after the opening meeting dialogue and before the first shared choice.
- Added Shared-03 MOVE to `EAGLE_SORROW` after arrival dialogue and before Longma's recruitment choice.
- Updated Shared sequence graph regression to expect five canonical MOVE actions and validate current location plus visited history against each action's marker.
- Expanded the Shared-01 bridge test to verify the destination, and extended the production WUK-15 → Shared-01 smoke to run the opening dialogue / MOVE using production Journey UI and verify save/load.
- Extended the Longma battle bridge / production SceneTree cases to require Eagle Sorrow before battle and after victory.

## Why
The WorldMap should not show an empty or stale location as the player begins the Shared Journey or meets Longma. Story arrivals are authoritative mainline movement; optional travel rules remain separate.

## Systems affected
- Shared-01 and Shared-03 EventSequence graphs
- MainMenu → WUK-15 END → Shared-01 production SceneTree smoke
- Longma recruitment bridge / WorldMap current location
- Shared EventSequence movement regression

## Files
- `data/narrative/event_sequences.json`
- `combat/test_shared_event_sequences.gd`
- `combat/test_shared_battle_scene_transition.gd`
- `combat/test_shared_battle_journey_bridge.gd`
- `combat/test_shared_opening_journey_bridge.gd`
- `combat/test_origin_final_shared_handoff.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-shared-chapter-map-arrivals.md`
- `docs/development_log/2026-10-11-shared-opening-map-arrivals.md`

## Tests
- Shared event graph test expects five MOVE actions: Five Elements Mountain, Eagle Sorrow, Black Wind North Path, Gaojiazhuang and Flowing Sands.
- Production final-handoff smoke checks Five Elements Mountain after WUK-15 leads into Shared-01, including save/reload.
- Longma recruitment tests check Eagle Sorrow is committed before battle and does not revert during victory settlement.
- Runtime suite remains at 42 registered entries.

## Godot Runtime status
**PASS** — exact implementation commit `584db9e18ddd3d0a850f2779e9d1acb2e255b880`. Godot Runtime run [38117715977](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117715977) passed with `RUNTIME_SUITE_PASS tests=42` and explicit PASS lines for the Shared sequence graph, opening bridge, battle bridge, production Shared scene transition, and final handoff smoke. Web Demo run [38117715919](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117715919) build and deploy passed.

## Known issues
- Story MOVE is an authoritative mainline arrival and may enter a canonical node before that chapter's final timeline milestone is recorded. Free travel still observes WorldMapManager's timeline, milestone, and connection guards.
- Full map traversal animation and region art remain future vertical-slice work.

## Next step
After CI passes, exercise Shared-01 → Shared-02 → Shared-03 → Shared-04 with one persisted save, checking timeline, location, roster and completed chapters at every transition.

## Handoff point
Shared Journey opening and Longma recruitment. EventSequence chronology and current WorldMap marker should agree.
