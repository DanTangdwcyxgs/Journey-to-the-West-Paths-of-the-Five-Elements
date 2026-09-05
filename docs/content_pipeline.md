# Content Production Pipeline

## 1. Purpose

The project has moved from core architecture construction toward repeatable content production.

The long-term goal is to make a new chapter, encounter, event, map segment or memory chapter primarily a **content task**, not a new programming architecture task.

The production chain is:

`Content Data → Definition → Runtime Validation → Event Sequence → Event Runner → Event / Battle Handoff → Resolution → Narrative State → Presentation`

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

### Event sequence

Defines an executable graph of reusable nodes:

- `dialogue`
- `choice`
- `wait`
- `move`
- `battle`
- `reward`
- `jump`
- `end`

`EventSequenceDefinition` validates node IDs, node types, start node and graph targets.

`EventSequenceValidator` then validates cross-references into real content:

- choice → Event;
- battle → Encounter;
- battle → source Chapter;
- shared battle encounter must match the chapter's canonical encounter ID;
- namespace must be `ORIGIN` or `SHARED`.

`EventSequenceManager` rejects invalid sequences instead of placing them into the runtime catalog and exposes load errors for CI/content tooling.

`EventRunner` owns only execution state. It returns an action request to Presentation / World / Battle systems and can be serialized and restored while waiting on dialogue, choice, movement, reward or battle resolution.

EventRunner must remain UI-independent. A battle node produces `EncounterHandoff` data rather than opening BattleUI itself.

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

### EventSequenceDefinition

Provides one normalized graph contract for all executable narrative sequences. It is deliberately data-only and performs structural validation before a runner starts.

### EventSequenceValidator

Performs content cross-reference validation after structural validation. It should be used by content import / CI, not hidden inside UI code.

### EventSequenceManager

Loads valid sequence content into the runtime catalog. Invalid entries are rejected and recorded in `get_load_errors()` so future editor tooling and CI can report all bad content together.

### EventRunner

Owns the runtime state machine for a sequence:

- presents the next action;
- applies choices through `EventRuntime`;
- converts battle nodes to `EncounterHandoff`;
- pauses cleanly for external systems;
- resumes after battle resolution;
- serializes/restores the current node and pending action.

The runner does **not** perform UI, animation, pathfinding or combat itself.

### NarrativeEventSession

Owns a single in-progress event experience across scene boundaries. It combines `EventRunner` with serializable resume context and produces a Battle handoff without knowing which UI scene will present it.

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

Provides a neutral runtime contract for moving from exploration/narrative scenes into battle. `BountyEncounterState` remains the compatibility persistence implementation for now and can carry `event_resume` for active event sessions.

---

## 5. Production Rule: One Source of Truth

Do not store the same progression meaning in multiple systems.

Bad example:

- BattleUI marks a chapter complete;
- SharedJourneyManager marks the same chapter complete;
- event code separately marks the recruitment milestone.

Preferred example:

- EventRunner asks for a battle;
- BattleUI executes combat;
- BattleResolutionService atomically commits result + chapter progression;
- EventSession resumes presentation from its stored context;
- NarrativeState remains the only authority for world facts.

---

## 6. Current Production Sample

The first production-style executable sequence is:

`SHARED-03-EAGLE-SORROW-SEQUENCE`

Data file:

`data/narrative/event_sequences.json`

Flow:

`Arrival Dialogue → LONGMA_ENCOUNTER Choice → SHARED_EAGLE_SORROW Battle → After Battle Dialogue → END`

This is deliberately small. It exists to prove the production contract before expanding into the full Shared Journey and five Origin Routes.

---

## 7. Authoring Workflow

For a new executable scene:

1. Add or reuse Event definitions.
2. Add a sequence graph in `event_sequences.json`.
3. Run structural + cross-reference validation.
4. Confirm canonical `source_chapter_id` and encounter IDs.
5. Run EventRunner / EventSession regression.
6. Only then connect new presentation assets.

Content authors should not add new manager classes for ordinary chapters.

---

## 8. Current Quality Gate

A sequence is not considered production-ready unless:

- structural validation passes;
- all referenced events exist in the declared namespace;
- all battle encounters exist;
- source chapters exist;
- canonical encounter IDs match chapter data;
- runtime regression passes;
- Godot headless CI passes.

Current limitation: the quality gate does not yet validate every presentation asset or map marker referenced by `move` nodes.

---

## 9. Migration Policy

Old chapter/event code remains temporarily usable while content migrates.

Migration should be incremental:

`legacy content → Definition/Runtime compatibility → EventSequence → Presentation`

Do not rewrite all existing chapters in one commit. Migrate one real playable path, validate it, then continue.

---

## 10. Core Principle

**章节描述发生什么，Runtime 决定怎么执行，NarrativeState 保存事实，Presentation 只负责表现。**
