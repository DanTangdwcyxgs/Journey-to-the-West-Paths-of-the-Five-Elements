# Game Architecture

## 1. Architectural Principle

The project is split into four layers so narrative, combat, content, and presentation can evolve independently.

### Domain
Pure deterministic game rules: combatants, actions, turns, Break, BP, status effects, formation and battle state.

### Content
Data definitions for characters, skills, enemies, chapters, encounters, maps, dialogue and rewards. Content should be data-driven wherever practical.

### Narrative
The canonical Journey to the West timeline, five character routes, recruitment gates, chapter unlock rules, shared milestones and convergence rules.

### Presentation
Godot scenes, UI, animation, VFX, camera, audio and exploration presentation. Presentation observes game state and narrative state; it must not own core rules.

---

# 2. Narrative Structure: Five Origins → Five Journeys → One Journey

The game is built around five protagonists:

- Sun Wukong
- Tang Sanzang
- Zhu Bajie
- Sha Wujing
- Bai Longma

At a new game, the player chooses **any one** as their starting protagonist. There is no canon-mandated first protagonist.

Each protagonist has a substantial personal route. A route begins from that character's own life and worldview, reaches the canonical moment where that character encounters or joins the pilgrimage, and then hands the character into the shared party timeline.

> **A character becomes available to the party at the same canonical event where that character joins the Journey to the West.**

Recruitment is a narrative payoff, not a menu unlock.

Once a protagonist joins, later personal chapters can unlock at defined world milestones. These chapters deepen the character without breaking the global chronology.

---

# 3. The Two Orders

The game maintains two different kinds of order.

## Player Order

Which protagonist's personal story the player experiences first.

The player is free to start with Wukong, Tang, Bajie, Wujing or Longma.

## World Order

The chronological sequence of the Journey to the West.

World order is fixed. Major canonical events cannot be rearranged simply because the player selected a different starting hero.

**Player order is free. World order is fixed.**

The save system must track both independently.

---

# 4. Macro Narrative Structure

The campaign is divided into four macro acts.

## Act I — Five Origins

Each protagonist has an independent origin campaign. The origin campaign ends at the character's canonical recruitment or pilgrimage commitment point.

The origin routes are deliberately substantial. They are not five tutorials with different skins.

## Act II — The Growing Party

The player follows the shared pilgrimage timeline while the party grows according to canonical encounters.

Each recruitment must do three things:

1. resolve an important part of the recruit's personal story;
2. change the party's combat capabilities;
3. create a new relationship or conflict inside the group.

## Act III — Five Perspectives, One Journey

Once a full party exists, the main story is shared, but personal chapters continue to appear as optional or semi-required perspective chapters.

These chapters should reveal motivations, relationships, memories and conflicts that the shared route cannot fully cover.

## Act IV — The Final Shared Journey

The final arc belongs to all five characters. The game stops behaving like five parallel character campaigns and becomes one ensemble story.

Major bosses, major decisions and final consequences are shared party events.

---

# 5. Canonical Origin Routes

The following is the initial narrative backbone. Individual chapters may be expanded later, but the recruitment anchors should remain stable unless the project deliberately changes its interpretation of Journey to the West.

## 5.1 Sun Wukong — Freedom vs Restraint

Wukong is the strongest opening route for players who want the most action-heavy start, but he must not become the default canon route simply because he is iconic.

### Origin sequence

1. Birth from the celestial stone
2. Flower Fruit Mountain and life among the monkeys
3. Awareness of mortality
4. Journey to seek immortality
5. Puti Zushi and cultivation
6. Transformations and Somersault Cloud
7. Dragon Palace and the Ruyi Jingu Bang
8. Underworld and the Register of Life and Death
9. Recruitment by Heaven as Bimawen
10. Rejection of the low position
11. Qitian Dasheng and the first rebellion
12. Peach Garden conflict
13. Escalation with Heaven
14. Erlang Shen confrontation
15. Furnace of Taishang Laojun and Fire Eyes
16. Havoc in Heaven
17. Buddha's intervention
18. Five Elements Mountain

### Recruitment relationship

Wukong is not recruited by another playable character during his origin. He is imprisoned first.

His recruitment event occurs when Tang Sanzang reaches Five Elements Mountain and releases him.

### Design requirement

Wukong's origin must establish his central conflict before Tang ever becomes part of his daily life. The player should understand why the later golden fillet / discipline conflict matters emotionally.

The 1986 TV adaptation also places the early Wukong material before Tang's pilgrimage and then moves into Five Elements Mountain and Wukong becoming Tang's disciple.

## 5.2 Tang Sanzang — Faith vs Reality

Tang must have a real protagonist route rather than functioning as a healer who is waiting for Wukong.

### Origin sequence

1. Childhood and early religious formation
2. Becoming a monk
3. Buddhist study and discipline
4. Encounter with the political and religious world around him
5. Imperial mission to seek scriptures
6. Meeting Guanyin
7. Accepting the pilgrimage
8. Departure from Chang'an
9. Early road dangers
10. Five Elements Mountain
11. Releasing Wukong
12. First master-disciple conflict

### Recruitment relationship

Tang begins as an independent protagonist when selected at New Game.

When his route reaches Five Elements Mountain, Wukong becomes available as the first major combat recruit.

### Design requirement

Tang's route must make his decisions understandable even when the player disagrees with them. He should not be written as naive simply to make Wukong look clever.

## 5.3 Bai Longma — Identity vs Duty

Bai Longma is the most unusual party member and should have one of the most surprising origin structures.

### Origin sequence

1. Identity as the White Dragon Prince
2. Life within the Dragon Court
3. Family expectations and conflict
4. The event that puts him on the pilgrimage path
5. Punishment and exile
6. Eagle Sorrow Stream
7. Encounter with Tang's pilgrimage
8. Conflict with the group
9. Guanyin's intervention
10. Becoming the white horse
11. First period of service to Tang

### Recruitment relationship

Chronologically, Longma enters the pilgrimage before Zhu Bajie and Sha Wujing become permanent disciples.

For gameplay, Longma should initially exist as a story character / mount rather than immediately functioning as a normal combat unit. His full playable combat identity can awaken later.

### Design requirement

This creates a deliberately delayed reveal: the player may spend hours knowing Bai Longma as the horse before discovering the deeper combat identity.

## 5.4 Zhu Bajie — Desire vs Responsibility

Bajie's origin should be one of the longest pre-recruitment stories because his personality becomes much richer when the player understands who he was before becoming the pig demon of Gaojiazhuang.

### Origin sequence

1. Marshal Tianpeng and heavenly life
2. Pride and appetite
3. Relationship with the celestial order
4. The incident that causes his fall
5. Rebirth into his pig-demon form
6. Wandering in the mortal world
7. Arrival at Gaojiazhuang
8. Relationship with the Gao family
9. Increasing conflict and shame
10. Tang and Wukong arrive
11. Recruitment battle
12. Reluctant commitment to the pilgrimage

### Recruitment relationship

Bajie becomes a permanent party member at Gaojiazhuang.

The 1986 adaptation places the recruitment of Zhu Bajie after the Guanyin Monastery material.

### Design requirement

The player should understand that Bajie's humor is a defense mechanism, not his entire character.

## 5.5 Sha Wujing — Guilt vs Redemption

Wujing should be the quietest and most restrained origin route.

### Origin sequence

1. Life as a heavenly general
2. The celestial punishment incident
3. Exile to the Flowing Sands River
4. Isolation
5. Repeated encounters with travelers
6. Survival and guilt
7. Guanyin's intervention
8. The pilgrims arrive
9. Repeated attempts to cross the river
10. Recognition of the pilgrimage as a path to redemption
11. Joining Tang

### Recruitment relationship

Wujing becomes a permanent party member at the Flowing Sands River.

The 1986 adaptation places his recruitment after Bajie's recruitment and the group's early journey.

### Design requirement

Wujing should not be written as merely the "third quiet guy". His route should establish a distinct worldview and a strong reason for choosing responsibility over isolation.

---

# 6. Canonical Recruitment Spine

The initial party timeline should use the following anchor events:

**Wukong origin → Wukong imprisoned → Tang begins pilgrimage → Tang reaches Wukong → Wukong recruited → Bai Longma joins the pilgrimage as the mount → Zhu Bajie recruited at Gaojiazhuang → Sha Wujing recruited at Flowing Sands River → early shared pilgrimage → full-party campaign.**

This preserves the broad rhythm of the classic adaptation while leaving room for the game to expand the characters' personal stories.

The 1986 TV sequence specifically places Wukong's imprisonment before Tang's journey, then Wukong's recruitment, Zhu Bajie's recruitment, and Sha Wujing's recruitment in that broad order.

---

# 7. How Alternative Starting Characters Work

The game must never pretend that selecting Bajie magically moves the entire world into a different chronology.

Instead, the selected protagonist's origin is played as a **historical character route**. Once it reaches its chronological anchor, the player enters the shared timeline at the corresponding point.

Example: starting as Bajie does not mean the pilgrimage has already happened. It means the player experiences Bajie's history up to Gaojiazhuang first. After recruitment, the global timeline becomes the pilgrimage timeline and future events proceed normally.

Similarly:

- Starting as Wukong begins before Tang's pilgrimage.
- Starting as Tang begins during the preparation and launch of the pilgrimage.
- Starting as Longma begins from the dragon's own life and reaches the pilgrimage before the later disciples join.
- Starting as Bajie begins in Heaven / his exile and reaches Gaojiazhuang.
- Starting as Wujing begins with his heavenly punishment and isolation before the pilgrims arrive.

This produces different opening experiences without creating five incompatible universes.

---

# 8. Chapter Categories

Every chapter belongs to exactly one primary category.

## Origin Chapter

A character-only or mostly character-focused chapter before recruitment.

Origin chapters may temporarily ignore the full party because the party does not yet exist.

## Recruitment Chapter

The canonical encounter where a character enters the pilgrimage.

Recruitment chapters are major narrative payoffs and should normally contain a boss or set-piece encounter.

## Shared Journey Chapter

A chapter where the growing party advances along the common timeline.

## Character Perspective Chapter

An optional or milestone-gated chapter focused on one character after recruitment.

It may occur as a flashback, side route, personal quest or off-screen parallel story.

## Major Trial Chapter

A major Journey to the West event such as White Bone Demon, Yellow Wind, Flaming Mountain or another large-scale mythological trial.

## Interlude

Short scenes that develop relationships, camp conversations, memories, humor or worldbuilding without requiring a full dungeon.

---

# 9. Chapter Unlock Rules

A chapter is playable only when all of its prerequisites are satisfied.

Minimum requirements:

1. `character_requirement` — the character must be available unless the chapter is an origin chapter.
2. `timeline_gate` — the global chronology must have reached the required point.
3. `chapter_prerequisites` — required earlier chapters must be complete.
4. `spoiler_guard` — the chapter must not reveal future events unless explicitly marked as a flashback.

Example:

`wukong_origin_01` requires no previous party members.

`wukong_recruitment` requires `FIVE_ELEMENTS_MOUNTAIN_REACHED`.

`bajie_recruitment` requires `GAOJIAZHUANG_REACHED`.

`wujing_recruitment` requires `FLOWING_SANDS_RIVER_REACHED`.

`white_bone_perspective_wukong` requires `WHITE_BONE_DEMON_APPROACH`.

---

# 10. No Replaying the Same Story Five Times

When multiple protagonists are present at one canonical event, there is one authoritative version of the event.

Other character routes may show:

- a pre-event memory;
- a parallel scene;
- a private conversation;
- the aftermath;
- a different interpretation of what happened.

They should not force the player to replay the same full dungeon and boss five times unless deliberately designed as a special variant.

This is essential for pacing. The player should feel that the world is continuing, not that the game is resetting the same chapter for every character.

---

# 11. Narrative Pacing Rules

The project should follow these rhythm rules.

### Rule 1 — Personal stories first, party story later

The player must have enough solo content to understand the protagonist before recruitment changes the game.

### Rule 2 — Recruitment changes gameplay immediately

Every recruitment must add a meaningfully different combat role, not merely another skin.

### Rule 3 — Every recruitment changes relationships

New party members should create friction, humor, trust or ideological conflict with existing members.

### Rule 4 — The party should grow in visible stages

The player should feel the difference between:

`Solo → Duo → Small Group → Full Five → Ensemble`

### Rule 5 — Full party is not the ending of character stories

After all five are assembled, individual character arcs become more important, not less. The shared route should create the circumstances that force old personal conflicts to resurface.

### Rule 6 — Canonical events are anchors, not cages

Major Journey to the West events should remain recognizable. Original scenes and connective stories can be inserted between anchors so the game becomes a full RPG rather than a compressed retelling.

---

# 12. Narrative State Model

The save system must track narrative state explicitly.

`SaveNarrativeState`

- `starting_character`
- `current_global_timeline`
- `completed_chapters`
- `completed_milestones`
- `recruited_characters`
- `unlocked_character_chapters`
- `character_relationship_state`
- `active_shared_chapter`

The narrative state must not be inferred solely from the current scene.

A player can leave a chapter, reload, switch perspective and continue without losing the global chronology.

---

# 13. Data Model Requirements

## CharacterDefinition

- `id`
- `name`
- `origin_chapter_ids`
- `recruitment_milestone`
- `combat_role`
- `skill_set`
- `narrative_theme`

## ChapterDefinition

- `id`
- `character_id`
- `sequence_index`
- `timeline_gate`
- `prerequisites`
- `scene_ids`
- `encounter_ids`
- `reward_ids`
- `completion_milestone`
- `chapter_type`
- `is_origin`
- `is_shared`
- `is_flashback`

## WorldMilestone

- `id`
- `chronological_index`
- `title`
- `description`

## RecruitmentEvent

- `character_id`
- `trigger_milestone`
- `scene_id`
- `resulting_party_change`
- `unlocks`

---

# 14. Initial Global Milestones

These IDs are stable identifiers for the first narrative implementation:

1. `WUKONG_ORIGIN_COMPLETE`
2. `WUKONG_IMPRISONED`
3. `TANG_PILGRIMAGE_BEGUN`
4. `FIVE_ELEMENTS_MOUNTAIN_REACHED`
5. `WUKONG_RECRUITED`
6. `BAI_LONGMA_RECRUITED`
7. `GAOJIAZHUANG_REACHED`
8. `ZHU_BAJIE_RECRUITED`
9. `FLOWING_SANDS_RIVER_REACHED`
10. `SHA_WUJING_RECRUITED`
11. `EARLY_PILGRIMAGE_COMPLETE`
12. `WHITE_BONE_DEMON_APPROACH`
13. `WHITE_BONE_DEMON_COMPLETE`
14. `PARTY_FULL`
15. `SHARED_JOURNEY_BEGUN`

The IDs may map to different exact chapter numbers during content production, but once used by save files they must be treated as stable.

---

# 15. Combat Boundary

The combat engine remains independent from narrative progression.

Narrative code may request:

- create encounter
- add or remove party member
- set battle modifier
- award chapter rewards
- mark milestone

Narrative code must not calculate damage, Break or BP.

The same combat engine must be reusable by:

- solo origin encounters;
- recruitment battles;
- shared journey battles;
- optional trials;
- boss phases;
- the final campaign.

---

# 16. Production Runtime Architecture

The project now uses a production-oriented boundary between **content definitions**, **runtime decisions**, **state mutation** and **presentation**.

```text
Content JSON
    ↓
ChapterDefinition / other normalized definitions
    ↓
ChapterRuntime / specialized managers
    ↓
NarrativeManager + NarrativeState
    ↓
Combat / World / Memory systems
    ↓
Presentation
```

The important rule is that presentation should consume runtime state rather than becoming the owner of progression rules.

## 16.1 ChapterDefinition

`ChapterDefinition` is the normalized interface for chapter content. It prevents every UI or manager from reaching directly into raw JSON keys.

Supported contract includes:

- id
- title
- chapter type
- owner character
- timeline
- required character / world requirement
- prerequisites
- event id
- encounter id
- scene ids
- rewards
- world effects
- recruitment events
- next chapter
- origin / memory / shared flags

Legacy data keys remain readable during migration.

## 16.2 ChapterRuntime

`ChapterRuntime` currently owns read-only, side-effect-light decisions:

- can a chapter be entered;
- are chapter prerequisites complete;
- is the destination an event, battle or plain chapter;
- which encounter is requested;
- which chapter follows.

This layer intentionally starts small. Full mutation logic will migrate here gradually only after regression coverage exists.

## 16.3 Narrative State API

Persistent choices and progression facts should be changed through explicit `NarrativeState` methods.

For example:

- origin choices use `record_origin_choice()`;
- shared choices use `record_shared_choice()`;
- shared choices are read through `get_shared_choice()`.

Event managers should not invent their own persistent dictionary structures.

## 16.4 Battle Handoff

`EncounterHandoff` is the neutral contract for moving from exploration or narrative content into combat.

`BountyEncounterState` remains the current persisted compatibility implementation so the migration does not break existing world/battle flow.

The long-term goal is:

`World / Chapter Runtime → EncounterHandoff → BattleUI → BattleResolutionService`

## 16.5 Battle Resolution Boundary

Narrative battle victory follows one transaction boundary:

```text
validate source
    ↓
preview rewards
    ↓
record battle result
    ↓
progress route / shared chapter
    ↓
apply recruitment / world effects
    ↓
set next state
    ↓
save once
```

Any failure after mutation must restore the previous narrative snapshot.

This prevents partial states such as:

- reward granted but chapter not completed;
- character recruited but world milestone missing;
- chapter completed twice;
- stale battle handoff granting duplicate rewards.

## 16.6 Reward Ownership

Encounter rewards and chapter rewards are deliberately separate.

A recruitment battle grants its encounter reward. A non-combat chapter can grant its chapter reward.

A recruitment chapter should not silently grant the same reward a second time during chapter completion.

---

# 17. Content Production Architecture

The architecture is now prepared for batch content production.

Future chapter production should normally require:

```text
chapter JSON
+ event JSON
+ encounter JSON (if needed)
+ map / scene references
+ regression test for critical transition
```

New gameplay rules should be added only when the content genuinely introduces a new reusable mechanic.

The goal is to make adding Chapter 25 primarily a **content task**, not a new architecture task.

See `docs/content_pipeline.md` for the detailed authoring and migration rules.

---

# 18. Migration Strategy

Existing systems should not be rewritten wholesale for aesthetic reasons.

Migration order:

1. normalize existing content with `ChapterDefinition`;
2. move read-only discovery and prerequisite checks to `ChapterRuntime`;
3. move duplicated mutations into established narrative services;
4. connect presentation through the stable runtime contracts;
5. remove legacy duplicated paths only after regression coverage exists.

This keeps the playable prototype stable while the architecture evolves toward mass content production.
