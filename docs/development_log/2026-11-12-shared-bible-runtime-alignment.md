# 2026-11-12 — Shared Pilgrimage Bible Runtime Alignment

## Goal
Remove obsolete Shared chapter numbering and align the narrative Bible with the executable nine-chapter catalog. Identify any canonical-order gaps instead of hiding them behind generic chapter labels.

## Audit sources
- `data/narrative/shared_chapters.json`
- `data/narrative/event_sequences.json` (namespace SHARED)
- `data/narrative/shared_pilgrimage.json`
- `data/world/world_map.json`
- `scripts/world/yellow_wind_ridge_manager.gd`
- `combat/test_yellow_wind_ridge_cave_progression.gd`
- `combat/test_yellow_wind_cave_battle_roundtrip.gd`
- `combat/test_yellow_wind_king_settlement_retry.gd`

## Findings
1. Rewrote `docs/shared_pilgrimage_chapter_bible.md` around the actual runtime catalog:
   SHARED-01 Five Elements (T100), SHARED-02 Early Pilgrimage (T105), SHARED-03 Eagle Sorrow (T110), SHARED-04 Black Wind / Early Demon Tales (T120), SHARED-05 Gaojiazhuang (T130), SHARED-06 Four-Person Journey (T140), SHARED-07 Flowing Sands (T150), SHARED-08 Party Full (T160), SHARED-09 Full Pilgrimage (T170).
2. Reconfirmed all five starting-route handoff boundaries: Wukong/Tang → Shared-01; Longma → Shared-03; Bajie → Shared-05; Wujing → Shared-07. TANG-09 and LONGMA-07/08 remain outside the executable Origin endpoint by design.
3. Compared each chapter with its actual EventSequence and current evidence. The Bible now calls out where a chapter is only a story/exploration shell and lists missing narrative, encounter, reward, or presentation work.
4. Found a substantive chronology gap: the canonical novel order puts Gaojiazhuang (chapters 18–19), Yellow Wind Ridge (20–21), then Flowing Sands (22). Current Shared data links Shared-05 Gaojiazhuang → Shared-06 Four-Person Journey → Shared-07 Flowing Sands and has no Yellow Wind chapter.
5. The Yellow Wind Ridge/Cave/King vertical slice is real and has progression, save rollback, battle return and boss-settlement tests. But it is not a Shared chapter: there is no Yellow Wind record in `shared_chapters.json`, and its completion does not advance Shared chapter/global timeline. It must not be counted as TRIAL-013/014 mainline-complete yet.
6. Current Ridge unlock uses timeline 120 plus Longma recruitment, while Gaojiazhuang is timeline 130. Treat this as existing optional/vertical-slice gating, not proof of canonical mainline chronology.

## Recommended resolution (documented, not yet implemented)
- Insert a formal Yellow Wind Shared chapter after SHARED-06 and before SHARED-07. Proposed ID: `SHARED-06A-YELLOW-WIND`; proposed time window 140–150. Final gate, exact timeline, state transition and failure rollback need to be implemented together.
- Reuse the existing Ridge/Cave/Boss screens and content; do not duplicate a separate Yellow Wind dungeon.
- Keep optional Yellow Fang (`BOUNTY_YELLOW_FANG`) independent from mainline Yellow Wind King (`YELLOW_WIND_KING`).
- The next implementation must atomically complete the inserted Shared chapter and advance to Flowing Sands only after the mainline Yellow Wind King result is committed. Save failure must leave the encounter and chapter retryable.

## Regression added
- Added `combat/test_shared_bible_runtime_alignment.gd` and registered it in `tests/runtime_suite.gd`.
- It cross-checks every current Shared chapter's ID/title/timeline/sequence/next row against runtime JSON, verifies the nine-chapter next-link chain, and rejects the obsolete SHARED-01/02/04 headings.
- It also asserts that the Yellow Wind insertion is documented as a proposal, not falsely claimed as a registered runtime chapter.

## Files changed
- `docs/shared_pilgrimage_chapter_bible.md`
- `combat/test_shared_bible_runtime_alignment.gd`
- `tests/runtime_suite.gd`
- `docs/development_log/2026-11-12-shared-bible-runtime-alignment.md`
- `docs/development_log/README.md`
- `docs/AI_MEMORY.md`
- `AI_HANDOFF.md`

## Validation
- Runtime validation is pending for the new implementation/test SHA. Do not reuse the preceding 53/53 result.
- No gameplay data, battle logic, asset, or shared chronology was changed in this documentation and regression-contract batch.
- No PR merge or deployment was performed.

## Next
1. Run exact-head Godot Runtime; correct any parser/test mismatch.
2. Implement the formal Yellow Wind chapter insertion with save-atomic chapter advancement.
3. Build a dedicated post-recruitment Memory catalog for LONGMA-07/08.
