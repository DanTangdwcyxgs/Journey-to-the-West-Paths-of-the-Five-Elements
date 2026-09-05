# Black Myth: Wukong — JRPG Edition

> 东方神话 × 像素 HD-2D × 回合制 JRPG × 五人独立主线汇流

A pixel-art HD-2D turn-based JRPG that follows the recognizable narrative rhythm of **Journey to the West**, especially the classic television-style progression, while using modern JRPG systems and presentation.

## Core Vision

The project is **a playable Journey to the West story first, and an original fantasy JRPG second**.

The main narrative should remain highly recognizable as Journey to the West. Iconic characters, recruitment points, major locations, relationships and major pilgrimage episodes form the canonical story spine.

The game language is modern HD-2D JRPG:

- pixel-art characters;
- dimensional environments;
- cinematic lighting and weather;
- turn-based party combat;
- Weakness / Break;
- BP / Boost;
- character-specific combat mechanics;
- strong JRPG menus and battle feedback.

See [Game Vision & Canon](docs/game_vision.md), [Global Timeline](docs/global_timeline.md), [Story Structure & Chapter Pacing](docs/story_structure.md), [Memory Campaign Rules](docs/memory_campaign.md), [Combat Formation](docs/combat_formation.md), and [Production Rules](docs/production_rules.md).

## Core Narrative Loop

The defining narrative loop is:

`Choose a hero → experience that hero's origin → reach a canonical encounter → recruit/meet another character → immediately unlock that character's personal story → return to the current shared journey → meet the next character → repeat → full party → ensemble journey.`

**Personal-story unlock is tied to recruitment/encounter progression. It does not wait for the five-person party to be complete.**

## Exploration Loop

After the shared journey reaches a valid world node, the player can enter the world map, travel between connected locations, hear local rumors and convert those rumors into persistent bounty intelligence. Exploration records visited nodes, heard rumors and discovered bounties without rewinding or rewriting the main chronology.

The current exploration spine is:

`五行山 → 鹰愁涧 → 黑风山北道 → 高老庄 → 流沙河 → 龙骨秘境`

The world map is data-driven through `data/world/world_map.json` and `data/world/rumors.json`; runtime state is persisted in the narrative save.

A discovered Yellow Wind bounty now continues into a real battle-scene handoff: **hear rumor → discover bounty → travel to target area → accept → battle → resolve rewards + journal + world effects**. The encounter handoff itself is transient so abandoned battles do not corrupt the canonical narrative save.

The preparation loop now adds **camp records, shop supply, persistent equipment profiles, and battle consumables**. Equipment choices are written into `NarrativeState`; combat reads the saved profiles before creating the encounter.

The first dedicated **Yellow Wind Ridge → Yellow Wind Cave → Yellow Wind Demon** path is now represented as a data-driven exploration slice with a four-stage ridge and a four-room cave greybox.

## Gameplay Pillars

- **5-character party:** Tang Sanzang, Sun Wukong, Zhu Bajie, Sha Wujing, Bai Longma
- **Formation:** 3 front / 2 back tactical formation with swapping and persistence
- **Recruited-roster battles:** combat construction respects the saved recruited party instead of forcing all five protagonists into every encounter
- **Back-row protection:** back-row units take reduced normal single-target damage
- **Break / Weakness:** exploit enemy weaknesses to break their shield
- **BP Boost:** accumulate BP and spend it to strengthen actions
- **Speed-based turns:** dynamic initiative affected by speed changes
- **Data-driven skills:** character skill definitions live in `data/combat/skills.json` and are executed by `SkillRuntime`
- **Character-specific mechanics:** every protagonist changes how encounters are approached
- **Bai Longma transformation:** four temporary combat forms driven by Dragon Shift resource
- **81 Trials:** major stories, personal quests, elite encounters and optional events
- **World exploration:** connected map nodes, rumors, bounty discovery and persistent journey information
- **Preparation / supplies:** shops, camp records, equipment profiles and combat consumables

## Current Combat Foundation

Implemented and connected:

- HP / ATK / DEF / SPD / BP
- weakness tags
- shield points
- Broken state
- increased damage while Broken
- BP generation and spending
- speed-based turn ordering
- narrative party formation → combatant construction
- front/back row modifiers
- back-row damage protection
- data-driven skill catalog
- damage / heal / barrier / slow / taunt / self-buff skill effects
- persistent battle results, inventory rewards and journey log
- persistent equipment/loadout configuration
- battle consumable usage and inventory deduction
- readable temporary combat status presentation for Break, barrier, taunt and speed changes
- saved loadout modifiers applied inside combat formulas
- functional Bai Longma form shift with temporary stat changes and expiry
- recruited-party-aware battle construction
- Yellow Wind bounty battle handoff and automatic victory reward resolution
- shared encounter definitions for Eagle Sorrow, Gaojiazhuang and Flowing Sands
- shared encounter CombatEngine regression coverage for weakness targeting, AI turns, defeat resolution and deterministic ally victory
- atomic shared-chapter mutation with rollback coverage for late recruitment/world-effect failures
- unified narrative battle-resolution service with preflight validation, reward preview, progression rollback and a single final save boundary

## Current World Foundation

Implemented and connected:

- data-driven world map nodes and connections
- timeline / milestone travel gates
- persistent current location and visited nodes
- local rumor discovery
- persistent bounty intelligence from rumors
- world-map UI linked from the journey screen
- discovered bounty challenge button for the first integrated bounty encounter
- transient world-map → battle encounter handoff
- Yellow Wind Ridge four-stage exploration slice
- Yellow Wind Cave four-room greybox slice
- persistent cave room checkpoints in `NarrativeState`
- cave → normal encounter battle source-stage handoff
- cave → bounty battle source-stage handoff
- post-victory return into the Yellow Wind Ridge flow
- camp / supply / preparation entry points
- unified origin-route lifecycle API with deterministic chapter unlock/progress reporting
- data-driven shared-journey chapter spine with recruitment, rewards and world-effect metadata
- data-driven shared-journey narrative events with persisted choices
- journey-screen integration for shared event choices before chapter completion
- regression checks for travel, rumor discovery, bounty handoff, combat status, Longma transformation, normal encounter construction, recruited roster handling, origin route lifecycle, shared journey chronology, and shared event choices

## Roadmap

### Phase 1 — Foundation

- [x] Repository bootstrap
- [x] Combatant model
- [x] Weakness / shield / Break rules
- [x] BP system
- [x] Speed-based turn ordering
- [x] Regression tests
- [x] Narrative architecture
- [x] Five-character route structure
- [x] Global timeline and production canon
- [x] Progressive character-story unlock rules
- [x] Party formation persistence
- [x] Shared recruitment events
- [x] Formation-aware combatant construction
- [x] Basic front/back combat effect
- [x] Data-driven skill definitions
- [x] Skill runtime effects
- [x] Persistent inventory / rewards / journey log
- [x] Persistent equipment/loadout configuration
- [x] Battle consumables
- [x] World map / travel / rumor discovery layer
- [x] First bounty encounter handoff
- [x] Combat status presentation
- [x] Narrative data model implementation
- [x] Shared journey chapter data model
- [x] Shared journey narrative event layer
- [x] Shared encounter CombatEngine regression coverage
- [x] Shared chapter atomic rollback coverage
- [x] Unified narrative battle-resolution service foundation
- [ ] Wire unified battle-resolution service into BattleUI
- [ ] Minimal battle UI polish

### Phase 2 — Playable Vertical Slice

- [ ] Five playable characters
- [x] Five origin chapter prototypes
- [x] Front/back formation swap
- [x] Bai Longma transformation states
- [x] Basic skills/resources foundation
- [x] Canonical recruitment event flow
- [x] Progressive personal-story unlock flow
- [x] Shared journey narrative event flow
- [x] World exploration prototype
- [x] Battle consumable loop
- [x] First complete battle: Yellow Wind Demon path
- [x] First dungeon greybox
- [x] Persistent dungeon checkpoints
- [ ] Visual combat polish
- [ ] Fully authored five-character playable route content
