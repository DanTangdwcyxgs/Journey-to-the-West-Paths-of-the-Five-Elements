# Content Production Pipeline

## 1. Purpose

The project has moved from core architecture construction toward repeatable content production.

The long-term goal is to make a new chapter, encounter, event, map segment or memory chapter primarily a **content task**, not a new programming architecture task.

The production chain is:

`Content Data → Definition → Runtime Validation → Event / Battle Handoff → Resolution → Narrative State → Presentation`

Gameplay rules must stay in reusable systems. Individual chapters should describe **what happens**, while runtime systems decide **how the rules execute**.

---

## 2. Required Content Layers

### Narrative chapter

Defines:

- `id`
- `title`
- `chapter_type`
- `owner_character`
- `timeline`
- `required`
- `prerequisites`
- `event`
- `encounter_id`
- `scene_ids`
- `rewards`
- `world_effects`
- `recruit`
- `next`
- `is_origin`
- `is_memory`
- `is_shared`

### Event

Defines:

- `event_id`
- `title`
- dialogue / presentation content
- choices
- choice effects
- optional follow-up event

Event content must not mutate `NarrativeState` directly. Use `EventDefinition` + `EventRuntime` and explicit `NarrativeState` APIs.

### Encounter

Defines:

- encounter id
- enemies
- stats
- weaknesses
- shields
- skills
- AI profile
- encounter rewards
- encounter world effects

The battle system owns combat rules. Narrative code owns the meaning of the battle's result.

### World content

Defines:

- map nodes
- connections
- travel requirements
- rumors
- bounty discovery
- dungeon stages / rooms
- checkpoints

World content should report facts to narrative state rather than duplicating narrative progression logic.

---

## 3. Chapter Categories

Use one primary category per chapter:

- `ORIGIN` — pre-recruitment personal history.
- `RECRUITMENT` — canonical party-joining event.
- `SHARED_JOURNEY` — common pilgrimage chronology.
- `MEMORY` — post-recruitment flashback / character perspective.
- `MAJOR_TRIAL` — major canonical Journey to the West event.
- `INTERLUDE` — short character, camp or travel scene.
- `SIDE_STORY` — optional original content.

A chapter may additionally set `is_origin`, `is_memory`, and `is_shared` for compatibility with older content data, but `chapter_type` should become the preferred source of truth.

---

## 4. Runtime Responsibilities

### ChapterDefinition

Normalizes content dictionaries into a stable interface so UI and managers do not depend on raw JSON keys everywhere.

### ChapterRuntime

Provides common chapter discovery and routing decisions:

- can the chapter be entered;
- are its prerequisites satisfied;
- is it an event, battle or plain chapter destination;
- what encounter is requested;
- what chapter comes next.

The current implementation is intentionally conservative and mostly side-effect free. More execution responsibilities should migrate here gradually, after regression coverage exists.

### EventDefinition

Normalizes event data and choice definitions. It keeps presentation-oriented event data out of state mutation code.

### EventRuntime

Owns reusable choice execution:

- validates the event and namespace;
- rejects repeated choices;
- validates that the selected choice exists;
- applies supported persistent effects;
- records the choice through `NarrativeState`.

Current supported generic effects:

- `relationship_values`
- `milestones`
- `world_rumors`
- `memory_chapters`

Character-specific combat modifiers remain available through the existing origin-event compatibility layer and should not be moved into generic event effects without a concrete schema need.

### NarrativeManager / NarrativeState

Own canonical persistent facts:

- timeline;
- chapters completed;
- milestones;
- recruited roster;
- memories;
- relationships;
- party formation;
- inventory;
- world state;
- choices.

Presentation must not become the source of truth.

### BattleResolutionService

Own the transaction boundary for victorious narrative battles:

`validate → preview rewards → record result → progress narrative → save once`

Failures must restore the pre-resolution snapshot.

### EncounterHandoff

Provides a neutral runtime contract for moving from exploration/narrative scenes into battle. `BountyEncounterState` remains the compatibility persistence implementation for now.

---

## 5. Production Rule: One Source of Truth

Do not store the same progression meaning in multiple systems.

Bad example:

- BattleUI marks a chapter complete;
- SharedJourneyManager marks the same chapter complete;
- event code separately marks the recruitment milestone.

Preferred example:

`BattleUI → BattleResolutionService → SharedJourneyManager → NarrativeManager / NarrativeState`

The UI displays the resulting state.

---

## 6. Production Rule: Event Choice Ownership

Events may present choices and calculate their configured effects, but persistent choice storage belongs to `NarrativeState` through explicit APIs.

Current namespaces:

- origin: `record_origin_choice(chapter_id, choice_id)`
- shared event: `record_shared_choice(event_id, choice_id)`

Future relationship / world / quest namespaces should follow the same explicit pattern.

---

## 7. Production Rule: Reward Ownership

Use this separation:

### Encounter reward

Reward attached to successfully defeating a battle encounter.

### Chapter reward

Reward attached to completing a non-combat chapter.

A recruitment battle should not receive the same reward again from the chapter completion step unless that duplication is intentional and explicitly documented.

---

## 8. Production Rule: Narrative Transaction

Any operation that can partially mutate multiple persistent systems must use a transaction boundary.

Minimum transaction shape:

1. Validate source and current state.
2. Snapshot persistent state.
3. Apply reward preview.
4. Apply journal / milestone / progression changes.
5. Apply recruitment and world effects.
6. Set next state.
7. Save exactly once.
8. Restore snapshot on failure.

This rule is mandatory for future multi-system chapter resolution.

---

## 9. Chapter Authoring Workflow

For a new chapter:

1. Define its canonical narrative purpose.
2. Assign its category and timeline position.
3. Define prerequisites.
4. Define event data.
5. Define encounter(s) if needed.
6. Define rewards and world effects.
7. Define recruitment changes if any.
8. Define next destination.
9. Add the minimum regression test for its critical state transition.
10. Only then integrate presentation assets.

This ordering prevents art and UI from becoming coupled to unstable narrative logic.

---

## 10. Vertical Slice Workflow

A vertical slice should be produced end-to-end rather than implementing isolated systems.

Target flow:

`World node → NPC / rumor → exploration → event → normal encounter → camp / preparation → dungeon → recruitment or boss → resolution → aftermath → next destination`

The first complete slice is intended to use the existing:

`Five Elements Mountain → Eagle Sorrow → White Dragon → Black Wind / Yellow Wind travel → Yellow Wind Ridge → Yellow Wind Cave → Yellow Wind Demon`

This slice becomes the reference implementation for future chapter production.

---

## 11. Migration Policy

Do not rewrite existing working systems solely for elegance.

Migrate one responsibility at a time:

1. wrap old raw data with `ChapterDefinition` / `EventDefinition`;
2. route read-only discovery through `ChapterRuntime`;
3. route choice execution through `EventRuntime`;
4. move common side effects into shared services only when covered by tests;
5. remove duplicated old logic after the new path is verified.

This keeps the project playable while architecture evolves.

---

## 12. Quality Gate Before Marking a Feature Complete

A feature is not considered complete solely because its script exists.

The preferred gate is:

- data exists;
- runtime path is connected;
- state transition is persistent;
- invalid/stale input is rejected;
- duplicate resolution is safe;
- at least one regression test exists;
- the feature is reflected in project documentation;
- Godot runtime verification is explicitly recorded when actually executed.

Never claim runtime success when only static/code inspection was performed.
