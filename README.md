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

Example:

`Tang → meet Wukong → Wukong story unlocks → continue Tang/Wukong journey → meet Longma → Longma story unlocks → continue → meet Bajie → Bajie story unlocks.`

## Five Protagonist Structure

At New Game, the player can choose **Sun Wukong, Tang Sanzang, Zhu Bajie, Sha Wujing, or Bai Longma** as the first protagonist.

The choice selects the player's first narrative lens. It does not rewrite world chronology.

> **Player order is free. World chronology is fixed.**

Each protagonist has a substantial origin route. Their story eventually reaches the recognizable point where they become connected to the pilgrimage.

## Canonical Party Backbone

The broad recruitment sequence remains:

`Wukong imprisoned → Tang pilgrimage → Wukong recruited → Bai Longma joins → Zhu Bajie recruited → Sha Wujing recruited → full shared journey`

The project may expand the connective material around these events, but the major recruitment anchors should remain stable unless the narrative canon is deliberately revised.

## Five Character Themes

| Character | Core Theme | Origin Focus |
|---|---|---|
| Sun Wukong | Freedom vs Restraint | Flower Fruit Mountain, immortality, Heaven, Five Elements Mountain |
| Tang Sanzang | Faith vs Reality | Monastic life, mission, departure, pilgrimage |
| Zhu Bajie | Desire vs Responsibility | Tianpeng, fall, rebirth, Gaojiazhuang |
| Sha Wujing | Guilt vs Redemption | Heavenly punishment, Flowing Sands River |
| Bai Longma | Identity vs Duty | Dragon Court, punishment, Eagle Sorrow Stream |

## Gameplay Pillars

- **5-character party:** Tang Sanzang, Sun Wukong, Zhu Bajie, Sha Wujing, Bai Longma
- **Formation:** 3 front / 2 back tactical formation with swapping and persistence
- **Back-row protection:** back-row units take reduced normal single-target damage
- **Break / Weakness:** exploit enemy weaknesses to break their shield
- **BP Boost:** accumulate BP and spend it to strengthen actions
- **Speed-based turns:** dynamic initiative affected by speed changes
- **Character-specific mechanics:** every protagonist changes how encounters are approached
- **Bai Longma transformation:** delayed full combat identity and multiple forms
- **81 Trials:** major stories, personal quests, elite encounters and optional events

## Visual Direction

Target visual language:

**pixel protagonists + dimensional environments + dramatic lighting + atmospheric depth + Chinese mythological scenery.**

The project is not intended to reproduce another game's proprietary assets or exact art. The goal is the broader modern HD-2D JRPG visual language combined with Journey to the West imagery.

## Combat Prototype

The current codebase focuses on a deterministic, testable combat simulation.

Implemented foundation:

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
- headless regression tests

## Narrative Architecture

Narrative progression is separate from combat implementation.

### Chapter Types

- **Origin Chapter** — pre-recruitment personal story
- **Recruitment Chapter** — canonical encounter where a character joins
- **Shared Journey Chapter** — common pilgrimage timeline
- **Character Perspective / Memory Chapter** — personal story unlocked when that character becomes relevant
- **Major Trial Chapter** — major Journey to the West story / boss arc
- **Interlude** — camp, relationship, memory and worldbuilding

### Memory Rule

A recruited/encountered character immediately gains an eligible personal-story pool. Individual memories may still be spoiler-gated by the global timeline, but the basic route unlock is **not** gated by `PARTY_FULL`.

`PARTY_FULL` only unlocks the ensemble layer: full formation, five-way party interactions, group scenes and full shared-party content.

## Global Timeline

The save system tracks chronological `current_global_timeline` separately from:

- `starting_character`
- each character's route progress
- recruited characters
- shared chapter progress
- historical/flashback unlocks
- saved party formation

## Repository Layout

```text
combat/
  combatant.gd       # combatant state + front/back row
  combat_action.gd   # skill/action definitions
  combat_engine.gd   # turn loop, weakness, break, damage, BP, formation effects
  battle_demo.gd     # small runnable battle setup
  test_combat.gd     # headless combat regression tests

scripts/combat/
  combat_party_builder.gd  # party formation -> Combatant construction

scripts/party/
  party_manager.gd          # five-person roster and formation

docs/
  architecture.md
  game_vision.md
  global_timeline.md
  global_chapter_map.md
  story_structure.md
  character_routes_overview.md
  character_bible.md
  chapter_plan.md
  production_rules.md
  production_plan.md
  narrative_state.md
  narrative_content_schema.md
  memory_campaign.md
  combat_formation.md
  sun_wukong_route.md
  tang_sanzang_route.md
  bai_longma_route.md
  zhu_bajie_route.md
  sha_wujing_route.md
  tv_episode_alignment.md

data/
  combat/party_profiles.json
  narrative/shared_pilgrimage.json

project.godot
.gitignore
README.md
```

## Run

1. Install Godot 4.x.
2. Open this repository as a Godot project.
3. Run the project scene configured in `project.godot`.
4. For command-line regression testing:

```bash
godot --headless --path . --script res://combat/test_combat.gd
```

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
- [ ] Narrative data model implementation
- [ ] Minimal battle UI

### Phase 2 — Playable Vertical Slice

- [ ] Five playable characters
- [ ] Five origin chapter prototypes
- [x] Front/back formation swap
- [ ] Bai Longma transformation states
- [ ] Skills, resources and status effects
- [x] Canonical recruitment event flow
- [x] Progressive personal-story unlock flow
- [ ] First complete battle: Yellow Wind Demon
- [ ] First dungeon greybox

### Phase 3 — Shared Journey

- [x] Shared recruitment/convergence backbone
- [ ] Full party convergence chapter
- [ ] Major Journey to the West story arcs
- [ ] Progressive character perspective / memory chapters
- [ ] Relationship and camp dialogue system
- [ ] Journal / 81 Trials system
- [ ] 12–15 major trials
- [ ] 20–25 minor trials

### Phase 4 — Polish

- [ ] HD-2D lighting and post-processing
- [ ] Pixel character animation
- [ ] Boss presentation camera
- [ ] Music and SFX
- [ ] Controller support
- [ ] Steam integration

## Development Principles

1. **Journey to the West is the narrative spine.**
2. **JRPG systems are the interactive language.**
3. **HD-2D pixel art is the presentation language.**
4. **Canonical events anchor the world timeline.**
5. **Meet/recruit a character, then unlock that character's story.**
6. **Personal stories can be explored before the party is complete.**
7. **Original content expands the journey instead of replacing it without reason.**
8. **Narrative rules and combat rules remain independently testable.**
9. **New mechanics should extend the existing state model instead of duplicating state in UI scenes.**

## Note on IP

This repository is a fan-project prototype. Any commercial release, final naming, art, assets, character presentation, dialogue adaptation and distribution strategy should receive appropriate rights review before release.
