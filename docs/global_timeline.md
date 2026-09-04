# Global Story Timeline

This document is the canonical world chronology. Character routes may be entered in any order, but shared-world events must resolve against this timeline.

## Timeline Rules

- `timeline_index` is monotonic for the shared world.
- An origin chapter may occur at an earlier historical index than the current shared timeline when it is explicitly marked as an origin/flashback.
- A canonical event has one authoritative gameplay owner.
- Recruitment gates are tied to canonical events, not player level.
- Optional content may add detail but must not contradict a completed milestone.

## Macro Timeline

### T00 — Mythic Prelude

World creation, ancient gods, the broader mythic setting and the spiritual order of the world.

This is mostly environmental/background material and should not become a long playable prologue.

### T10 — Wukong Is Born

Stone birth → Flower Fruit Mountain → monkey kingdom.

Primary route: Wukong.

### T20 — Wukong Seeks Immortality

Departure from the mountain → journey to seek a master → Puti Zushi → training.

Primary route: Wukong.

### T30 — Wukong Arms Himself

Dragon Palace → Ruyi Jingu Bang → supernatural equipment and transformation.

Primary route: Wukong.

### T40 — Wukong Defies Death

Underworld / Register of Life and Death → return to the mortal world.

Primary route: Wukong.

### T50 — Heaven Takes Notice

Recruitment into Heaven → Bimawen → rejection → return to Flower Fruit Mountain.

Primary route: Wukong.

### T60 — Qitian Dasheng

Heaven attempts to contain Wukong → Wukong claims the Great Sage title → Peach Garden / banquet conflict.

Primary route: Wukong.

### T70 — Havoc in Heaven

Heavenly pursuit → Erlang Shen confrontation → furnace → Fire Eyes → final rebellion.

Primary route: Wukong.

### T80 — Five Elements Mountain

Buddha defeats Wukong → Wukong is sealed.

**World milestone:** `WUKONG_IMPRISONED`

This is the principal convergence point between Wukong's origin and Tang's pilgrimage.

### T90 — Tang Sanzang Begins the Pilgrimage

Tang's personal history → imperial mission → Guanyin's guidance → departure from Chang'an.

Primary route: Tang.

### T100 — Five Elements Mountain / Wukong Released

Tang reaches the mountain → Wukong is released → master/disciple relationship is established.

**Recruitment:** Wukong enters Tang's travelling party.

**Milestones:** `TANG_PILGRIMAGE_BEGUN`, `WUKONG_RECRUITED`

This event is one of the game's most important narrative handoffs.

### T110 — White Dragon / Longma

The party encounters the White Dragon's story → Longma's identity and curse are revealed → he becomes the pilgrimage mount.

**Recruitment state:** Longma is part of the journey as the mount.

**Milestone:** `BAI_LONGMA_RECRUITED`

Combat implementation may initially keep Longma in a limited/non-standard role while the narrative reveals his full identity.

### T120 — Early Pilgrimage

The new group travels through early canonical dangers. This phase establishes the first party dynamic:

- Tang and Wukong clash over method.
- Wukong becomes the main offensive protector.
- Longma is the silent constant of the road.
- The game begins recurring camp and travel conversations.

### T130 — Gaojiazhuang / Zhu Bajie

The party reaches Gaojiazhuang → Bajie's local story unfolds → confrontation with Bajie → his motives and past are revealed → recruitment.

**Milestone:** `ZHU_BAJIE_RECRUITED`

The tone can move between comedy and genuine pathos.

### T140 — Yellow Wind / Early Major Trials

A sequence of regional trials establishes the game's main JRPG loop: town → route → dungeon → boss → aftermath, with character scenes between them.

### T150 — Flowing Sands River / Sha Wujing

The party reaches the river → repeated attempts to cross → Wujing's punishment and loneliness are revealed → confrontation → Guanyin's intervention → recruitment.

**Milestone:** `SHA_WUJING_RECRUITED`

At this point the five core protagonists are together in the travel group, although the exact mechanical treatment of Longma may still evolve.

### T160 — First Full-Party Chapter

The party experiences its first major problem that requires all five characters to contribute.

This is the emotional transition from:

`heroes meeting each other`

to:

`the pilgrimage party becoming a family.`

**Milestones:** `PARTY_FULL`, `SHARED_JOURNEY_BEGUN`

### T170+ — Shared Pilgrimage

The main campaign now follows the recognizable pilgrimage rhythm through the major Journey to the West episodes.

The exact event list can expand during content production, but major recognizable stories should be anchored on this shared timeline.

Potential major sequence includes:

- Guanyin / Black Rooster / Yellow Robe and related early trials
- White Bone Demon
- Black Bear / Guanyin Monastery consequences
- Red Boy
- Spider Demon arc
- Lion / Elephant / Roc arcs
- Princess Iron Fan / Flame Mountain
- other major canonical monster-country episodes
- Heavenly encounters and divine interventions
- final scripture journey

Each major arc is divided into:

`arrival → local conflict → investigation → dungeon/region → boss → consequence → relationship/camp chapter → onward journey`

### T900 — Final Pilgrimage Arc

The journey reaches its final major challenges.

The final act must make the five-character party feel fully established and should pay off individual themes introduced in their origin stories.

### T990 — Scripture / Completion

The journey reaches its canonical spiritual conclusion.

The ending should resolve both:

1. the pilgrimage mission;
2. the five protagonists' individual character arcs.

## Character Route Overlay

### Wukong

Origin: `T10–T80`

First major shared participation: `T100+`

Character perspective chapters continue to unlock through the shared timeline.

### Tang

Origin: historical material leading into `T90`

Shared protagonist from `T90+`.

### Longma

Origin: pre-recruitment dragon story

Recruitment/state transition around `T110`.

### Bajie

Origin: Tianpeng → punishment → mortal life → Gaojiazhuang

Recruitment: `T130`.

### Wujing

Origin: celestial punishment → Flowing Sands River

Recruitment: `T150`.

## Canonical Event Ownership Rule

If an event appears in several character routes, one implementation owns the full event.

Other routes may show:

- a memory;
- a brief parallel scene;
- an aftermath;
- a different dialogue perspective;
- an optional side story.

They must not create multiple contradictory versions of the same canonical event.

## Main Narrative Invariants

The following should remain stable unless the project owner explicitly revises the canon:

1. Wukong's mythic origin occurs before Tang's pilgrimage.
2. Wukong is imprisoned before Tang releases him.
3. Wukong becomes Tang's principal first companion.
4. Longma becomes the pilgrimage mount.
5. Bajie is encountered and recruited at Gaojiazhuang.
6. Wujing is encountered and recruited at Flowing Sands River.
7. The five-character party eventually becomes the central cast.
8. Major Journey to the West stories remain recognizable.
