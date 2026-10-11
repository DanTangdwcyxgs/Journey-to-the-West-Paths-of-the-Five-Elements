# 2026-10-11 · Shared Chapter Story Arrival Locations

## Goal
Keep the WorldMap current location aligned with the canonical Shared Journey as the player reaches Gaojiazhuang and Flowing Sands through main-story event sequences.

## Starting point
- Shared-04 uses a story MOVE to `BLACK_WIND_NORTH_PATH`; this mainline location commit and its save-failure retry passed on exact commits `0aa7d6bffb22c03d05f51d95a09ee3e57f1927d5` (Runtime 40/40, Web Demo pass) and `1b84b1abcf668b9d2d96412822fa00c7a43a9ecc` (Runtime 41/41, Web Demo pass).
- The optional WorldMap → rumor → Yellow Fang bounty → return integration passed on commit `d387b16ab7af58fb4e841a257c6c053e430056f4`: Runtime [38117052682](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117052682) 42/42, Web Demo [38117052652](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38117052652) build/deploy pass.
- Shared-05 and Shared-07 were missing explicit MOVE nodes, so Story UI could progress into those recruitment battles while WorldMap's current location still reflected an earlier area.

## What changed
- Inserted a MOVE node between arrival dialogue and recruitment choice in Shared-05, targeting `GAOJIAZHUANG`.
- Inserted a MOVE node between river dialogue and recruitment choice in Shared-07, targeting `FLOWING_SANDS`.
- Expanded the Shared event graph regression from one hard-coded MOVE to all declared canonical markers, requiring both current location and visited-node history to update when an EventRunner completes MOVE.
- Expanded the real SceneTree recruitment-battle smoke to verify each new story location is persisted before entering BattleUI and remains correct in the post-victory save.

## Why
The story owns fixed chapter chronology while WorldMap owns optional connections and travel. Story MOVE is an authoritative arrival; after it commits, the map must show the same place as the chapter currently being played. This avoids routing the player back to stale locations while preserving free-travel gating for optional exploration.

## Systems affected
- Shared-05 and Shared-07 EventSequence graphs
- EventRunner / WorldActionService MOVE projection
- WorldMap location persistence
- Shared recruitment SceneTree tests

## Files
- `data/narrative/event_sequences.json`
- `combat/test_shared_event_sequences.gd`
- `combat/test_shared_battle_scene_transition.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-world-map-rumor-bounty-return.md`
- `docs/development_log/2026-10-11-shared-chapter-map-arrivals.md`

## Tests
- Shared sequence graph test now validates all three story MOVE markers: North Path, Gaojiazhuang and Flowing Sands.
- Production SceneTree test verifies Shared-05 / Shared-07 MOVE state saves before battle entry, and persists across the victory return.
- Existing WorldMap rumor/bounty loop remains registered and green.
- Runtime suite remains at 42 registered entries because the changes extend two existing tests.

## Godot Runtime status
**PENDING** — only record green after Runtime and Web Demo pass on the exact implementation SHA.

## Known issues
- Story MOVE is authoritative and does not call WorldMapManager.can_visit(); optional free travel still uses the latter's connection/timeline/milestone guards.
- Story arrival is a logical map state plus current UI transition; full animated map traversal and region art remains future vertical-slice work.

## Next step
After exact-head CI passes, exercise the canonical Shared-04 → Shared-05 → Shared-06 → Shared-07 progression from a single persisted Journey save and confirm timeline, current location and recruit state remain aligned at each chapter transition.

## Handoff point
Shared mainline arrival. EventSequence chronology and current WorldMap location should agree; optional travel may branch without committing Shared chapter completion.
