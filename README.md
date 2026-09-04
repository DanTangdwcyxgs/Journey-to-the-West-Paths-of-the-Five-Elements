# Black Myth: Wukong — JRPG Edition

> 东方神话 × HD-2D × 回合制策略 JRPG × 五人独立主线汇流

A turn-based JRPG prototype inspired by **Journey to the West**, classic party-based JRPGs, and HD-2D presentation.

## Core Narrative Concept

The game is structured around **five independent protagonist origins that eventually converge into one pilgrimage**.

At New Game, the player can choose **Sun Wukong, Tang Sanzang, Zhu Bajie, Sha Wujing, or Bai Longma** as the starting protagonist.

Each protagonist has a substantial personal campaign. The player follows that character until reaching the canonical point where their story intersects the Journey to the West, then that character becomes part of the growing party.

The key design rule is:

> **Player order is free. World chronology is fixed.**

The broad recruitment backbone remains:

`Wukong imprisoned → Tang pilgrimage → Wukong recruited → Bai Longma joins → Zhu Bajie recruited → Sha Wujing recruited → full shared journey`

After all five characters are assembled, the game transitions from separate origins into a single ensemble campaign. Character perspective chapters continue to deepen their individual stories without creating five parallel main timelines.

See [Story Structure & Chapter Pacing](docs/story_structure.md) and [Game Architecture](docs/architecture.md).

## Five Character Themes

| Character | Core Theme | Origin Focus |
|---|---|---|
| Sun Wukong | Freedom vs Restraint | Flower Fruit Mountain, Heaven, Five Elements Mountain |
| Tang Sanzang | Faith vs Reality | Monastic life, imperial mission, pilgrimage |
| Zhu Bajie | Desire vs Responsibility | Marshal Tianpeng, fall, Gaojiazhuang |
| Sha Wujing | Guilt vs Redemption | Heavenly exile, Flowing Sands River |
| Bai Longma | Identity vs Duty | Dragon Court, punishment, Eagle Sorrow Stream |

## Gameplay Pillars

- **5-character party:** Tang Sanzang, Sun Wukong, Zhu Bajie, Sha Wujing, Bai Longma
- **Formation:** 3 front / 2 back tactical formation with swapping
- **Break / Weakness:** exploit enemy weaknesses to break their shield
- **BP Boost:** accumulate BP and spend it to strengthen actions
- **Speed-based turns:** dynamic initiative affected by speed changes
- **Character-specific mechanics:** each protagonist should play differently even before recruitment
- **Bai Longma transformation:** delayed full combat identity and multiple forms
- **81 Trials:** 12–15 major trials, 20–25 minor trials, plus elite encounters and events

## Combat Prototype

The current codebase focuses on a deterministic, testable combat simulation.

Core rules currently implemented:

- HP / ATK / DEF / SPD / BP
- weakness tags
- shield points
- Broken state
- increased damage while Broken
- BP generation and spending
- speed-based turn ordering
- headless regression tests

## Narrative Architecture

Narrative progression is data-driven and independent from combat implementation.

### Chapter Types

- **Origin Chapter** — pre-recruitment personal story
- **Recruitment Chapter** — canonical encounter where a character joins
- **Shared Journey Chapter** — common pilgrimage timeline
- **Character Perspective Chapter** — personal story after recruitment
- **Major Trial Chapter** — major mythological event / boss arc
- **Interlude** — camp, relationship, memory and worldbuilding scenes

### Global Timeline

The save system tracks a chronological `current_global_timeline` separately from the player's `starting_character` and completed character chapters.

Important milestones include:

`WUKONG_ORIGIN_COMPLETE`

`WUKONG_IMPRISONED`

`TANG_PILGRIMAGE_BEGUN`

`FIVE_ELEMENTS_MOUNTAIN_REACHED`

`WUKONG_RECRUITED`

`BAI_LONGMA_RECRUITED`

`GAOJIAZHUANG_REACHED`

`ZHU_BAJIE_RECRUITED`

`FLOWING_SANDS_RIVER_REACHED`

`SHA_WUJING_RECRUITED`

`PARTY_FULL`

`SHARED_JOURNEY_BEGUN`

## Tech Stack

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Target:** Windows PC / Steam
- **Architecture:** deterministic combat domain + data-driven content + narrative timeline + presentation layer

## Repository Layout

```text
combat/
  combatant.gd       # combatant state
  combat_action.gd   # skill/action definitions
  combat_engine.gd   # turn loop, weakness, break, damage, BP
  battle_demo.gd     # small runnable battle setup
  test_combat.gd     # headless combat regression tests

docs/
  architecture.md        # system + narrative architecture
  story_structure.md     # five routes, recruitment and chapter pacing

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
- [x] Five-character chapter structure
- [ ] Narrative data model implementation
- [ ] Minimal battle UI

### Phase 2 — Playable Vertical Slice

- [ ] Five playable characters
- [ ] Five origin chapter prototypes
- [ ] Front/back formation swap
- [ ] Bai Longma transformation states
- [ ] Skills, resources and status effects
- [ ] Recruitment event flow
- [ ] First complete battle: Yellow Wind Demon
- [ ] First dungeon greybox

### Phase 3 — Content Expansion

- [ ] 12–15 major trials
- [ ] 20–25 minor trials
- [ ] Mini trials / elite encounters
- [ ] Personal character quests
- [ ] Relationship and camp dialogue system
- [ ] Journal / 81 Trials completion system

### Phase 4 — Polish

- [ ] HD-2D lighting and post-processing
- [ ] Pixel character animation
- [ ] Boss presentation camera
- [ ] Music and SFX
- [ ] Controller support
- [ ] Steam integration

## Design Principles

1. **Build rules before assets.** Combat and narrative progression must be deterministic and testable.
2. **Canonical anchors, original connective tissue.** Recognizable Journey to the West events anchor the timeline; original content fills the spaces between them.
3. **Recruitment is a payoff.** A new party member must resolve part of their personal story and change the party mechanically and emotionally.
4. **No forced first protagonist.** Any hero can be the player's first perspective.
5. **Never duplicate the same major event five times.** One canonical event, multiple character perspectives.

## Note on IP

This repository is a fan-project prototype inspired by *Journey to the West* and contemporary mythological games. Final commercial naming, art, assets, characters, and other protected elements should be reviewed for appropriate rights before distribution.
