# 2026-10-11 · EventSequence Chapter Namespace Metadata Consistency

## Goal
Detect content that exists in the correct catalog but carries explicit chapter metadata contradicting the EventSequence namespace.

## Starting point
- `EventSequenceValidator` already verifies namespace catalog membership, event references, battle encounter references, source chapter alignment, Shared canonical encounter alignment and Origin source-route alignment.
- The Origin route chapter catalog currently stores basic chapter fields without `chapter_type`, `is_origin` or `is_shared`. Shared chapters do provide them, including valid `RECRUITMENT` and `INTERLUDE` chapter types. The validator must support both schemas rather than require legacy Origin records to invent metadata.
- Shared recruitment battle real SceneTree smoke passed on commit `895ee2b3324aae7cde21a6a41b74c882dfae7227`: Runtime [38106171552](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106171552) reported 36/36 entries; Web Demo [38106171496](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106171496) passed.

## What changed
- Added a namespace-metadata check to `EventSequenceValidator.validate()` for chapter dictionaries returned by the matching catalog.
- SHARED rejects explicit `chapter_type=ORIGIN`, `is_origin=true` and `is_shared=false`.
- ORIGIN rejects explicit `chapter_type=SHARED_JOURNEY`, `is_origin=false` and `is_shared=true`.
- The check deliberately allows valid Shared subtypes such as `RECRUITMENT` and `INTERLUDE`. For legacy Origin entries that do not carry these keys, route membership remains authoritative and missing keys are not treated as invalid.
- Added regression fixtures for all three contradictions in each direction. Full production catalog validation continues through the existing runtime suite test.

## Why
Catalog membership catches a sequence placed in the wrong catalog, but it cannot catch a future data edit that keeps the chapter in one catalog while marking that chapter as belonging to the other namespace.

## Systems affected
- EventSequence cross-reference validation
- Production narrative data quality gate
- Runtime regression suite

## Files
- `scripts/narrative/event_sequence_validator.gd`
- `combat/test_event_sequence_validator.gd`
- `AI_HANDOFF.md`
- `docs/AI_MEMORY.md`
- `docs/development_log/README.md`
- `docs/development_log/2026-10-11-shared-battle-scene-transition-smoke.md`
- `docs/development_log/2026-10-11-event-sequence-namespace-metadata-consistency.md`

## Tests
- Existing full production catalog validation now checks metadata consistency for actual loaded chapter definitions.
- Synthetic shared/origin fixtures each prove all three explicit contradictory fields are rejected.
- Existing missing event, missing encounter, invalid source chapter, namespace mismatch and Origin route mismatch tests remain intact.

## Godot Runtime status
**PASS** — exact implementation commit `3316ce96124ba7ff9e8a30f686e3d586b966a44a`. Godot Runtime run [38106312375](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106312375) passed with `PASS res://combat/test_event_sequence_validator.gd` and `RUNTIME_SUITE_PASS tests=36`. Web Demo run [38106312426](https://github.com/DanTangdwcyxgs/Journey-to-the-West-Paths-of-the-Five-Elements/actions/runs/38106312426) completed successfully; both build and deploy jobs passed. The assertions extend the existing test entry, so the suite remains at 36 registered entries.

## Known issues
- The check validates only metadata explicitly present. Legacy Origin chapter dictionaries currently omit the fields and continue to rely on Origin Route membership by design.
- Chapter types other than explicit namespace opposites are not prohibited; Shared subtypes remain valid.

## Next step
After Runtime / Web Demo validation, assess the full Wukong-to-Longma playable vertical slice and how Memory unlock/playback should enter the main Journey loop.

## Handoff point
Narrative content validation. Keep chronology and progression ownership in the chapter managers; this batch adds diagnostics and regression only.
