# Production Plan

This is the sequencing contract for narrative and system development. The goal is to fully specify a layer before using it as a dependency for the next layer.

## Phase 0 — Canon Lock

Deliverables:
- `game_vision.md`
- `production_rules.md`
- `global_timeline.md`
- `tv_episode_alignment.md`
- `character_bible.md`

Exit criteria:
- story source hierarchy is fixed;
- major recruitment order is fixed;
- every major shared event has one canonical owner;
- no gameplay implementation depends on an unresolved story rule.

## Phase 1 — Five Origin Routes

Order:
1. Sun Wukong
2. Tang Sanzang
3. Bai Longma
4. Zhu Bajie
5. Sha Wujing

For each route, finish these artifacts before starting the next:
- chapter list;
- chapter-by-chapter synopsis;
- map/location list;
- NPC list;
- enemy list;
- boss list;
- chapter gameplay loop;
- chapter rewards;
- milestone transitions;
- dialogue intent;
- recruitment handoff;
- route-story unlock schedule after the character is encountered.

Exit criteria:
- every chapter can be summarized in one sentence;
- every chapter has a beginning, gameplay body, climax and transition;
- every chapter has a known timeline index;
- every canonical event is tagged;
- every recruited character has a defined set of immediately safe story chapters;
- no character story is gated on `PARTY_FULL` unless it is explicitly an ensemble chapter.

## Phase 2 — Recruitment & Party Formation

Implement and document in chronological order:
- Five Elements Mountain / Wukong recruitment;
- White Dragon / Bai Longma mount state;
- Gaojiazhuang / Bajie recruitment;
- Flowing Sands River / Wujing recruitment;
- full-party convergence.

Recruitment must immediately emit a character-route unlock event. The player can leave the recruitment scene and enter that character's newly available historical/personal chapters before continuing the shared road.

Exit criteria:
- starting as any hero eventually reaches the same canonical shared timeline;
- recruitment is driven by narrative milestones;
- party state is deterministic and save-safe;
- each recruited character exposes the appropriate portion of their personal story immediately.

## Phase 3 — Progressive Character Memory / Perspective Layer

This phase is **not** a single post-`PARTY_FULL` campaign.

The memory/perspective layer begins during Phase 2 and continues through the shared pilgrimage.

Core rule:

> **Meet/recruit a character → unlock that character's story → return to the current journey.**

Example:

```text
Tang starts
→ Five Elements Mountain
→ Wukong recruited
→ Wukong story becomes available
→ player may enter Wukong memories
→ return to Tang + Wukong current journey
→ Longma joins
→ Longma story becomes available
→ return to current journey
→ Bajie joins
→ Bajie story becomes available
```

Rules:
- each character receives a curated sequence of playable personal chapters;
- the route unlocks progressively from the moment that character becomes relevant;
- historical chapters are gated individually for spoiler safety;
- memories never rewind the global world timeline;
- exiting a memory returns the player to the exact previous shared-world state;
- the starting character's route can remain more extensive because it is the player's first narrative lens;
- later recruits do not require the party to be complete before their stories can be explored;
- `PARTY_FULL` may unlock ensemble memories, group scenes and multi-character relationship content, but is not the basic gate for individual memories.

Exit criteria:
- every protagonist has an independently unlockable story route;
- unlock timing is tied to recruitment/encounter milestones;
- memory completion is save-tracked separately from world progress;
- the system supports returning to the shared chapter without chronology corruption.

## Phase 4 — Shared Pilgrimage

Build the main Journey to the West route using the TV alignment table as the narrative skeleton.

Each major arc gets:
- arrival;
- local story;
- investigation/social scene;
- exploration route;
- ordinary encounters;
- one or more special mechanics;
- boss/set piece;
- consequence;
- camp/relationship scene;
- optional newly unlocked character memories where appropriate;
- next destination.

The shared campaign should alternate naturally between main-road advancement and character-story deepening rather than treating memories as a separate endgame mode.

## Phase 5 — Systems Expansion

Only after several story arcs are locked:
- formation system;
- status effects;
- equipment;
- resources;
- Longma transformation;
- relationship abilities;
- journal / 81 Trials;
- world map and travel system.

## Phase 6 — Visual Vertical Slice

Use one completed canonical arc as the visual benchmark.

Benchmark target:
- pixel-art characters;
- dimensional/2.5D environment;
- Chinese architectural identity;
- cinematic lighting;
- weather/atmosphere;
- JRPG UI;
- battle camera.

Recommended first benchmark arc: Yellow Wind Ridge because its visual and combat gimmick naturally tests sand, visibility, wind and Break interactions.

## Phase 7 — Content Expansion

Only after the benchmark is stable:
- complete remaining shared pilgrimage arcs;
- complete minor trials;
- complete side stories;
- add optional relationship content;
- fill 81 Trials journal.

## Phase 8 — Polish & Release

- balance;
- accessibility;
- controller support;
- save migration;
- localization readiness;
- performance;
- audio;
- Steam integration;
- rights review before any public/commercial release.

## Anti-Rewrite Rule

A completed phase is not casually rewritten because a later idea sounds cooler.

When a new idea appears, classify it as:
- compatible extension;
- local revision;
- architecture revision;
- canon revision.

Canon revision requires explicit project-owner approval because it can invalidate downstream chapters, saves and content assets.
