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
- recruitment handoff.

Exit criteria:
- every chapter can be summarized in one sentence;
- every chapter has a beginning, gameplay body, climax and transition;
- every chapter has a known timeline index;
- every canonical event is tagged.

## Phase 2 — Recruitment & Party Formation

Implement and document in chronological order:
- Five Elements Mountain / Wukong recruitment;
- White Dragon / Bai Longma mount state;
- Gaojiazhuang / Bajie recruitment;
- Flowing Sands River / Wujing recruitment;
- full-party convergence.

Exit criteria:
- starting as any hero eventually reaches the same canonical shared timeline;
- recruitment is driven by narrative milestones;
- party state is deterministic and save-safe.

## Phase 3 — Memory / Perspective Campaign

After `PARTY_FULL`, implement the user's intended "everyone remembers their own story" layer.

Rules:
- each protagonist receives a curated sequence of playable memories;
- memories are not generic flashbacks but real short chapters;
- each memory explains a current relationship, fear, habit, ability or unresolved conflict;
- memory chapters are unlocked in a controlled order so they do not spoil future shared content;
- completing the required memory set advances the campaign to the next shared chapter block.

Exit criteria:
- all five characters have meaningful memory arcs;
- memory completion is save-tracked;
- the player feels that all five lives have now been understood before the story accelerates into the long shared pilgrimage.

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
- next destination.

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
