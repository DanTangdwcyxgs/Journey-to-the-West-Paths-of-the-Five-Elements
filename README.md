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

See [Game Vision & Canon](docs/game_vision.md), [Global Timeline](docs/global_timeline.md), [Story Structure & Chapter Pacing](docs/story_structure.md), and [Production Rules](docs/production_rules.md).

## Five Protagonist Structure

At New Game, the player can choose **Sun Wukong, Tang Sanzang, Zhu Bajie, Sha Wujing, or Bai Longma** as the first protagonist.

The choice selects the player's first narrative lens. It does not rewrite world chronology.

> **Player order is free. World chronology is fixed.**

Each protagonist has a substantial origin route. Their story eventually reaches the recognizable point where they become connected to the pilgrimage.

The intended experience is:

`Choose a hero → experience their origin → reach the canonical encounter → join the growing pilgrimage → unlock personal perspective chapters → assemble the five-person core → enter the shared Journey.`

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
- **Formation:** 3 front / 2 back tactical formation with swapping
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
- headless regression tests

## Narrative Architecture

Narrative progression is separate from combat implementation.

### Chapter Types

- **Origin Chapter** — pre-recruitment personal story
- **Recruitment Chapter** — canonical encounter where a character joins
- **Shared Journey Chapter** — common pilgrimage timeline
- **Character Perspective Chapter** — personal story after recruitment
- **Major Trial Chapter** — major Journey to the West story / boss arc
- **Interlude** — camp, relationship, memory and worldbuilding

### Global Timeline

The save system tracks chronological `current_global_timeline` separately from:

- `starting_character`
- each character's route progress
- recruited characters
- shared chapter progress
- flashback/history unlocks

## Repository Layout

```text
combat/
  combatant.gd       # combatant state
  combat_action.gd   # skill/action definitions
  combat_engine.gd   # turn loop, weakness, break, damage, BP
  battle_demo.gd     # small runnable battle setup
  test_combat.gd     # headless combat regression tests

docs/
  architecture.md        # system architecture and extension points
  game_vision.md         # top-level creative and adaptation canon
  global_timeline.md     # canonical world chronology
  story_structure.md     # character routes and chapter pacing
  production_rules.md    # rules for future narrative/gameplay content

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
- [ ] Narrative data model implementation
- [ ] Minimal battle UI

### Phase 2 — Playable Vertical Slice

- [ ] Five playable characters
- [ ] Five origin chapter prototypes
- [ ] Front/back formation swap
- [ ] Bai Longma transformation states
- [ ] Skills, resources and status effects
- [ ] Canonical recruitment event flow
- [ ] First complete battle: Yellow Wind Demon
- [ ] First dungeon greybox

### Phase 3 — Shared Journey

- [ ] Full party convergence chapter
- [ ] Major Journey to the West story arcs
- [ ] Character perspective / memory chapters
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
5. **Character-specific stories make recruitment meaningful.**
6. **Original content expands the journey instead of replacing it without reason.**
7. **Narrative rules and combat rules remain independently testable.**

## Note on IP

This repository is a fan-project prototype. Any commercial release, final naming, art, assets, character presentation, dialogue adaptation and distribution strategy should receive appropriate rights review before release.
