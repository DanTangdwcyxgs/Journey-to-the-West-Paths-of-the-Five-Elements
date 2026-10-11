# Journey MOVE Destination Names

## Goal
Make story MOVE prompts readable to players by showing the destination's localized world-map name instead of internal map and marker identifiers.

## Starting point
The production Journey presentation rendered map_id and marker_id directly (for example, WORLD_MAP and BLACK_WIND_NORTH_PATH). The canonical world-map catalog already stores localized node names, so duplicating a second name table in Presentation would create unnecessary drift.

## What changed
- Updated JourneyScreen._describe_move_action() to resolve the marker through WorldMapManager.get_node() and display its name field as “目的地：...”.
- Kept a fallback to the marker ID only when a marker has no usable catalog name, so malformed or future content remains diagnosable instead of silently hiding the destination.
- Updated the Journey presentation regression to require “目的地：黑风山北道” and reject leaking BLACK_WIND_NORTH_PATH in player-facing dialogue.
- Updated AI handoff, memory ledger, and development-log index.

## Why
MOVE is a player-facing transition, not a content-debug panel. Internal IDs are useful in logs but weaken immersion and make the next destination harder to understand. Reusing WorldMapManager preserves the existing data source of truth.

## Systems affected
- Presentation: Journey MOVE prompt only.
- Content lookup: read-only access to the existing WorldMapManager catalog.
- Regression: Journey event presentation test.
- No narrative state, save format, route chronology, movement validation, or world-action side effects changed.

## Files
- ui/journey.gd
- combat/test_journey_event_presentation.gd
- docs/development_log/2026-10-11-journey-move-destination-names.md
- docs/development_log/README.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Tests
- Updated combat/test_journey_event_presentation.gd to assert the localized destination and absence of the internal marker ID.
- PASS for implementation head be9147511b2dd7741443135dec08377935427e8c: [Godot Runtime run 38125834662](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38125834662) completed successfully, and the job log confirms RUNTIME_SUITE_PASS tests=47. This status-only follow-up records the exact observed result.

## Known issues
- Unknown marker IDs still fall back to the ID text; this is intentional as a diagnostic fallback. Existing production story markers are resolved from the canonical world-map catalog.
- This is a small presentation fix, not a full exploration-scene or final-art pass.

## Next step
After the exact-head Runtime check passes, continue the vertical-slice review at the player-experience level: whether the short Shared-02 interlude and optional exploration signposting provide enough breathing room between the Five Elements Mountain opening and the Eagle Sorrow recruitment encounter.

## Handoff point
The MOVE prompt now uses WorldMapManager's localized node name. Next reviewer should inspect pacing and exploration affordances without changing canonical chapter order or treating the optional Yellow Wind bounty as the full Yellow Wind Ridge mainline.
