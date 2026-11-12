# 2026-11-12 — 81 Trials Source Ledger and Mapping Correction

## Goal
Replace the empty 81-slot scaffold with a source-backed record set, verify chapter locators against the repository's pinned 100-chapter index, correct false-positive route-catalog gaps, and add a regression gate.

## Source decision
- Primary authority: *Journey to the West*, Chapter 99. Its numbered disaster ledger explicitly enumerates 1–80, then says one more ordeal is required. The following passage narrates the added Tongtian River / White Turtle episode.
- Trial 81 is therefore recorded as an editorially named closing episode ("通天河补一难"), explicitly marked as derived from the Chapter 99 closing narrative, not as an item printed in the preceding 80-item list.
- A secondary 81-trial crosswalk provides novel-chapter locators; these are recorded as secondary references, not as wording from the primary ledger.
- Novel chapter numbers are checked against the repository-pinned 100-chapter index at `data/narrative/reference/xiyouji_chapter_index.json` (upstream source commit `419a54fbaf368af463dd863b8271ec7bb176b3b3`).
- The source list preserves textual variants / editorial normalization: #6 “折从落坑” (alternate “落坑折从”), #39 has a missing Unicode glyph normalized to “金兜山遇怪”, #55 “稀柿同秽阻” (variant “稀柿衕秽阻”), and #70 “灭法国” / later “钦法国”.

## Findings and corrections
1. The first 80 canonical trial names and chapter locators are now stored under stable IDs `TRIAL-001`–`TRIAL-080`; #81 is separately marked as derived from Chapter 99's closing episode. The data file records line evidence, aliases, chapter references, source provenance, and project crosswalk status.
2. The previous audit's “missing Origin sequence” classification for `TANG-09` was wrong. The executable Tang start route ends at `TANG-08` and hands off to `SHARED-01`. TANG-09 is a legacy Shared early-journey design concept, not a missing start-route step.
3. The previous “missing Origin sequence” classification for `LONGMA-07/08` was wrong. The executable Longma start route ends at `LONGMA-06`, then joins `SHARED-03`. LONGMA-07/08 are post-recruitment mount/memory and combat-awakening concepts. They remain real content backlog, but must not extend LONGMA_ORIGIN because that would move the canonical handoff. The current MemoryPlayback lookup also depends on OriginRouteManager; a separate memory-content catalog is needed.
4. Found a chapter-number drift in `docs/shared_pilgrimage_chapter_bible.md`: the current data IDs are SHARED-01 Five Elements, 02 Early Pilgrimage, 03 Eagle Sorrow, 04 Black Wind / Early Demon Tales, 05 Gaojiazhuang, 06 Four-Person Journey, 07 Flowing Sands, 08 Party Full, 09 Full Pilgrimage. The Bible now has an explicit runtime-alignment table and corrected Longma/Bajie/Wujing convergence rows. Old design sections are marked as draft text until migrated.
5. The Yellow Wind Ridge / Cave / Yellow Wind King vertical slice exists with production save/rollback tests, but the current shared catalog has no dedicated canonical-trial chapter ID wired to it. It remains a vertical slice, not a completed mainline mapping for trials 13–14.

## Current crosswalk snapshot
- 81 source records: 80 ledger-listed + 1 Chapter 99 closing-episode-derived.
- 4 records have existing Shared chapter Runtime evidence: trial 9 -> SHARED-03; trial 12 -> SHARED-05; trials 15/16 -> SHARED-07.
- 3 records are partial crosswalks: trial 8 -> SHARED-01; trials 10/11 -> SHARED-04.
- 2 records have existing Yellow Wind vertical-slice evidence but are not wired to a canonical Shared chapter ID: trials 13/14.
- 72 records still have no direct project chapter mapping. No 81-trial completion number is claimed.

## Files changed
- `data/narrative/reference/canonical_81_trials.json`
- `combat/test_canonical_81_trials.gd`
- `tests/runtime_suite.gd`
- `docs/narrative/81_TRIALS_MASTER_TRACKER.md`
- `docs/shared_pilgrimage_chapter_bible.md`
- `docs/development_log/2026-11-12-81-trials-source-crosswalk.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Data construction check: 81 records; sequential IDs; 80 exact ledger list entries + 1 closing-episode-derived entry.
- Runtime regression added but not yet validated on this new head. The next step is to inspect the new exact-SHA Godot Runtime run and fix any script/data issues before reporting success.
- No gameplay state, battle logic, encounter data, or art asset was changed.
- No PR was merged and no deployment was performed.

## Next
1. Run the exact new head's Godot Runtime and verify `test_canonical_81_trials.gd` plus full suite output.
2. Finish migrating the stale Shared Bible prose to the runtime chapter IDs.
3. Design a separate post-recruitment Memory catalog for LONGMA-07/08, preserving the fixed starting-route handoff.
4. Wire the Yellow Wind vertical slice to a real Shared mainline chapter only after its content and order are approved.
5. Continue the 81-item crosswalk in canonical novel order; do not mark a trial complete until content and production evidence pass.
