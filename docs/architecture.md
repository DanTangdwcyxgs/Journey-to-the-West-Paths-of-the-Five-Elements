# Combat Architecture

## Layers

### 1. Domain

`Combatant`, `CombatAction`, and `CombatEngine` contain rules that should work without a Node scene or UI.

### 2. Content

Character, skill, enemy, and encounter definitions will move into Godot `Resource` or equivalent data assets as the project grows.

### 3. Presentation

Scenes, UI, particles, animation, camera motion, sound, and VFX observe combat state and signals. They must not implement damage, Break, BP, or turn-order rules themselves.

## Turn Model

1. Build a deterministic queue from living combatants and SPD.
2. Pop the next actor.
3. Start-of-turn processing grants BP and advances temporary Broken state.
4. Player/AI selects an action.
5. Engine resolves resource cost, damage, weakness, shield, Break and victory.
6. Rebuild initiative when an action can change effective speed later in development.

## Break Model

Weaknesses are represented as tags/elements. Each weakness hit normally removes one shield point plus any explicit shield damage on the action. When shield reaches zero, the target enters `BROKEN` for a short window. The current prototype uses a two-turn Broken window and a 2x damage multiplier as a deliberately simple baseline for tuning.

## Boost Model

BP is a per-character resource from 0–5. The prototype grants 1 BP on a living character's turn start. Actions define BP cost. Boosting is represented as a multiplier rather than multiple copies of an action, which keeps the combat API small and makes balance tuning centralized.

## Extension Points

The next systems should be additive:

- `FormationState`: front/back slot occupancy and swap rules
- `StatusEffect`: timed buffs, debuffs and control effects
- `BattleModifier`: arena/boss rules such as Yellow Wind
- `CharacterDefinition`: reusable base stats and skill loadout
- `EnemyDefinition`: stats, weaknesses, AI and phase definitions

The engine should remain deterministic enough for headless regression tests.
