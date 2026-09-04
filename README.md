# Black Myth: Wukong — JRPG Edition

> 东方神话 × HD-2D × 回合制策略 JRPG 原型

A turn-based JRPG prototype inspired by **Journey to the West**, classic JRPG party combat, and HD-2D presentation.

## Project Direction

The project is intentionally built as a **playable vertical prototype first**:

- 5-character party: Tang Sanzang, Sun Wukong, Zhu Bajie, Sha Wujing, Bai Longma
- Front-row 3 / back-row 2 formation with tactical swapping
- Break / Weakness system
- BP Boost system
- Speed-based turn order
- Buff / debuff / status-effect foundation
- Bai Longma stance/transform framework
- Data-driven enemies and skills
- Later: HD-2D environments, boss gimmicks, the 81 Trials journal, audio and polish

## Current Prototype

**Phase 1 — Combat Core**

The current codebase focuses on a deterministic, testable combat simulation. It does not depend on final art assets.

### Core Rules

- Each combatant has HP, ATK, DEF, SPD, BP, and a set of weaknesses.
- Exploiting a weakness reduces the target's shield by 1.
- Shield reaching 0 causes `BROKEN`.
- Broken targets cannot act during the break window and take increased damage.
- Each living combatant gains 1 BP at the start of their turn, up to 5.
- BP can be spent to amplify an action.
- Turn order is rebuilt from speed after each action so buffs/debuffs can change initiative.

## Tech Stack

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Target:** Windows PC / Steam
- **Architecture:** data-driven combat domain + presentation layer

## Repository Layout

```text
combat/
  combatant.gd       # combatant state
  combat_action.gd   # skill/action definitions
  combat_engine.gd   # turn loop, weakness, break, damage, BP
  battle_demo.gd     # small runnable battle setup
  test_combat.gd     # headless combat regression tests

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

### Phase 1 — Prototype

- [x] Repository bootstrap
- [x] Combatant model
- [x] Weakness / shield / Break rules
- [x] BP system
- [x] Speed-based turn ordering
- [x] Regression tests
- [ ] Minimal battle UI

### Phase 2 — Vertical Slice

- [ ] 5 playable characters
- [ ] Front/back formation swap
- [ ] Bai Longma transformation states
- [ ] Skills, MP/resource system, status effects
- [ ] First complete battle: Yellow Wind Demon
- [ ] First dungeon greybox

### Phase 3 — Content

- [ ] 12–15 major trials
- [ ] 20–25 minor trials
- [ ] Mini trials / elite encounters
- [ ] Journal / 81 Trials completion system

### Phase 4 — Polish

- [ ] HD-2D lighting and post-processing
- [ ] Pixel character animation
- [ ] Boss presentation camera
- [ ] Music and SFX
- [ ] Controller support
- [ ] Steam integration

## Design Principle

**Build the combat rules before the art pipeline.** Every major combat rule should be deterministic and testable without a visual scene, then exposed to the UI and animation layers.

## Note on IP

This repository is a fan-project prototype inspired by *Journey to the West* and contemporary mythological action games. Final commercial naming, art, assets, characters, and other protected elements should be reviewed for appropriate rights before distribution.
