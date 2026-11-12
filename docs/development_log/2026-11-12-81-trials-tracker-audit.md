# 2026-11-12 — 81 Trials Tracker and Content Coverage Audit

## Goal
Turn the project's broad 81 Trials philosophy into a traceable per-trial production ledger, and identify discrepancies between narrative Bible definitions and registered runtime content without inventing canonical trial names or completion counts.

## Audit performed
- Read the current main README, AI handoff, persistent AI memory, game vision, five-start route chapter Bible, Origin EventSequence catalog, and recent region exploration logs.
- Counted the Origin Bible chapter definitions: Wukong 15, Tang 9, Bajie 9, Wujing 8, Longma 8 = 49.
- Parsed `data/narrative/event_sequences_origin.json`: Tang 8, Bajie 9, Wujing 8, Longma 6 = 31 registered sequences.
- Identified concrete catalog gaps against the Bible: TANG-09 and LONGMA-07/08 are defined in the Bible but absent from the Origin catalog.
- Confirmed the design vision describes 81 trials as a mixture of major stories and smaller trials, not 81 large dungeons. No authoritative 81-entry mapping is currently maintained in the repository.

## Changes
- Added `docs/narrative/81_TRIALS_MASTER_TRACKER.md` with 81 stable tracking slots, status definitions, required evidence, known chapter/catalog crosswalk, audit findings, and execution order.
- Explicitly separated Origin chapters from canonical pilgrimage trials and separated planning/data/runtime/content/production acceptance states.
- Did not invent the canonical names or chapter mappings for the 81 trials. All 81 slots remain UNMAPPED until a source edition and chapter references are verified.
- This is a documentation-only audit. No gameplay code, narrative data, images, or runtime assets were changed.

## Validation
- Parsed the Origin catalog JSON successfully and counted 31 sequence entries.
- Compared those IDs against the route chapter Bible and identified the three missing IDs above.
- GitHub connector does not run Godot locally. No new Godot Runtime or Web Demo result is claimed for this documentation-only branch.
- Exact-head CI must be checked after the documentation commit.

## Known issues
- Need a declared canonical source edition and verified 81-trial list with chapter references.
- Need inspect all route/shared catalogs for orphan IDs, duplicate IDs, namespace mismatches and missing Bible chapters.
- Need determine whether Wukong's 15 sequences are loaded from the shared sequence catalog by the current manager and validator, then record the exact path/IDs in the crosswalk.
- Need inspect current Shared chapter content and avoid treating optional region clue points as canonical trials.

## Next step
Finish the source-backed 81-entry crosswalk, then repair TANG-09 and LONGMA-07/08 only after checking whether equivalent sequences already exist in other catalogs. Continue with one narrow content/runtime slice and exact-SHA validation.

## Handoff
Start with `docs/narrative/81_TRIALS_MASTER_TRACKER.md`, `docs/five_start_route_chapter_bible.md`, `data/narrative/event_sequences_origin.json`, and the shared sequence catalog. Preserve the fixed world chronology and do not count Origin chapters as pilgrimage trials.
