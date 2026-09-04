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

## Gameplay Pillars

- **5-character party:** Tang Sanzang, Sun Wukong, Zhu Bajie, Sha Wujing, Bai Longma
- **Formation:** 3 front / 2 back tactical formation with swapping and persistence
- **Back-row protection:** back-row units take reduced normal single-target damage
- **Break / Weakness:** exploit enemy weaknesses to break their shield
- **BP Boost:** accumulate BP and spend it to strengthen actions
- **Speed-based turns:** dynamic initiative affected by speed changes
- **Data-driven skills:** character skill definitions live in `data/combat/skills.json` and are executed by `SkillRuntime`
- **Character-specific mechanics:** every protagonist changes how encounters are approached
- **Bai Longma transformation:** delayed full combat identity and multiple forms
- **81 Trials:** major stories, personal quests, elite encounters and optional events

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
- regression tests for combat and skill runtime

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
- [ ] Narrative data model implementation
- [ ] Minimal battle UI

### Phase 2 — Playable Vertical Slice

- [ ] Five playable characters
- [ ] Five origin chapter prototypes
- [x] Front/back formation swap
- [ ] Bai Longma transformation states
- [x] Basic skills/resources foundation
- [x] Canonical recruitment event flow
- [x] Progressive personal-story unlock flow
- [ ] Status-effect presentation
- [ ] First complete battle: Yellow Wind Demon
- [ ] First dungeon greybox
