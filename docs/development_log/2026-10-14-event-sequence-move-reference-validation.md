# 2026-10-14 · EventSequence MOVE Map Reference Validation

## Goal
Close the explicit content-pipeline gap where story MOVE nodes could refer to missing or unknown WorldMap destinations.

## Finding
EventRunner emits map_id and marker_id as a MOVE action, and WorldActionService.apply_move() persists marker_id as the current location. If the marker is empty, the service falls back to map_id; without validation, that can write WORLD_MAP into a field that should store a real location ID.

## Changes
- EventSequenceValidator.validate() now rejects a MOVE node with no map ID, an unsupported map ID, no marker ID, or a marker absent from the loaded WorldMap catalog.
- The currently supported map identifier is WORLD_MAP; valid markers are resolved using WorldMapManager.nodes, which derives from data/world/world_map.json.
- Extended combat/test_event_sequence_validator.gd with one valid fixture plus four invalid-reference cases; all existing production sequences continue to be validated by the existing catalog test.
- Updated docs/architecture.md, docs/content_pipeline.md, docs/AI_MEMORY.md, AI_HANDOFF.md and this index.

## Files changed
- scripts/narrative/event_sequence_validator.gd
- combat/test_event_sequence_validator.gd
- docs/architecture.md
- docs/content_pipeline.md
- docs/development_log/README.md
- docs/development_log/2026-10-14-event-sequence-move-reference-validation.md
- docs/AI_MEMORY.md
- AI_HANDOFF.md

## Validation
- PASS: implementation/test head daa33bb02411173170912eedd037e6dbf1e226f8, Godot Runtime [38522405623](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38522405623), completed successfully. Logs contain PASS res://combat/test_event_sequence_validator.gd and RUNTIME_SUITE_PASS tests=54.
- PASS: documentation-sync head d5fcf00d8d2d0e360de3f50f1d597de28e2a2c7b, Godot Runtime [38522641916](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38522641916), completed successfully. Logs contain PASS res://combat/test_event_sequence_validator.gd and RUNTIME_SUITE_PASS tests=54. The subsequent result-recording documentation commit still needs its own exact-head Runtime check.
- No Web Demo deployment, final character PNG/WebP delivery, or screenshot acceptance is claimed.

## Next step / Handoff
1. Inspect the exact current PR-head Runtime after this result-recording update and require the full 54/54 pass.
2. Preserve the rule that MOVE only names resolvable locations; when adding new maps later, add an explicit catalog rather than weakening this validator.
3. Keep PR #29 open/unmerged without explicit permission. Final character art and screenshot review remain separate.
