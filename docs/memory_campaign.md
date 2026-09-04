# Memory Campaign: Five Lives Remembered

## Purpose

After the five core characters are assembled, the game enters a dedicated **Memory Campaign** before the long shared pilgrimage accelerates.

The purpose is exactly this emotional progression:

> First I knew one hero. Then I watched the others join. Now I understand all five people. Only then does their shared Journey truly begin.

The Memory Campaign is not a second universe and not a rewind of the main timeline. It is a set of playable historical chapters that lets the player experience the unfinished personal stories of the other protagonists and deepen the starting hero.

## State Transition

```text
Five characters recruited
        ↓
PARTY_FULL
        ↓
Camp / major interlude
        ↓
MEMORY_CAMPAIGN_UNLOCKED
        ↓
Five character memory arcs
        ↓
MEMORY_CAMPAIGN_COMPLETE
        ↓
SHARED_JOURNEY_ACT_I
```

## What the Player Does

The player receives a Memory Board with five routes:

- Wukong
- Tang Sanzang
- Zhu Bajie
- Sha Wujing
- Bai Longma

The starting character's route is marked **known**, while the other routes are initially **unknown** or **partially known**.

Each route contains several playable memories. Completing a route reveals the character's past, not just a cinematic biography.

## Memory Chapter Rules

Every memory must have:

- `historical_timeline_index`
- `memory_owner`
- `unlock_milestone`
- `spoiler_safe_until`
- `gameplay_identity`
- `present_day_payoff`

A memory is only available when revealing it cannot spoil a future shared event beyond its declared guard.

## Memory Arc Structure

Each character receives three layers.

### Layer 1 — Origin Memory

The player sees the character before the pilgrimage.

### Layer 2 — Missing Context

The player experiences an event that the shared campaign only referenced previously.

### Layer 3 — Present-Day Payoff

Returning from the memory unlocks a present-day scene, relationship change, ability, item, or battle technique that makes the past matter mechanically.

## Wukong Memory Arc

### WM-W01 — Flower Fruit Mountain
Revisit the carefree period before immortality became an obsession.

Present payoff: unlock a party camp scene where Wukong talks about the old troop.

### WM-W02 — Puti Zushi
Experience the discipline and warning behind Wukong's transformations.

Present payoff: advanced transformation skill becomes available.

### WM-W03 — Dragon Palace
Revisit how Wukong obtained the Ruyi Jingu Bang.

Present payoff: Wukong gains a weapon-specific Boost option.

### WM-W04 — Heaven's Bureaucracy
Experience Bimawen from Wukong's perspective.

Present payoff: new dialogue options when the party encounters celestial officials.

### WM-W05 — Erlang Shen
Revisit the rivalry and tactical defeat.

Present payoff: a reaction mechanic against shape-shifting enemies.

### WM-W06 — Five Elements Mountain
Only a short, emotionally focused memory. Do not replay the complete sealing sequence.

Present payoff: unlocks Wukong/Tang relationship scene about restraint.

## Tang Memory Arc

### WM-T01 — Childhood and Monastery
Establish Tang as a person before he becomes a symbol.

### WM-T02 — The Pilgrimage Decision
Play the moment he chooses the dangerous road despite safer alternatives.

### WM-T03 — Guanyin's Instruction
Reveal the burden placed on him by the pilgrimage mission.

### WM-T04 — First Days with Wukong
Show the fear, disagreement and early trust-building hidden between major shared events.

### WM-T05 — The Meaning of Protection
Explore why Tang sometimes restrains Wukong even when doing so appears irrational.

## Bajie Memory Arc

### WM-B01 — Marshal Tianpeng
A celestial military chapter emphasizing discipline, status and appetite.

### WM-B02 — The Fall
A serious chapter showing the consequence that transforms his identity.

### WM-B03 — Mortal Life
Explore hunger, loneliness, shame and his need for companionship.

### WM-B04 — Gaojiazhuang Before the Party
Return to the period just before Tang and Wukong arrive.

### WM-B05 — Why Bajie Stayed
Reframe his choice to continue the pilgrimage as an active decision rather than simple surrender.

## Wujing Memory Arc

### WM-S01 — General of Heaven
Show his disciplined identity before exile.

### WM-S02 — The Accident
Play the event that leads to punishment.

### WM-S03 — Flowing Sands
A survival chapter built around repetition and isolation.

### WM-S04 — The Waiting
Focus on travelers, rumors and the gradual collapse of hope.

### WM-S05 — The Offer
Replay the moment redemption becomes possible.

## Longma Memory Arc

### WM-L01 — Dragon Prince
Show the Dragon Court and family hierarchy.

### WM-L02 — The Crime and Punishment
Experience the chain of events that places Longma in the mortal world.

### WM-L03 — Eagle Sorrow Stream
Show Longma's fear, anger and loss of identity.

### WM-L04 — Becoming the White Horse
Focus on accepting a role chosen by circumstance.

### WM-L05 — The Dragon Beneath the Horse
First full playable hint of the later combat identity.

## Completion Rules

The player does not need to complete the five memory arcs in a single prescribed order unless a particular spoiler guard requires it.

Recommended default order:

1. Starting character's deeper memory
2. Tang / Wukong relationship memory
3. Bajie
4. Wujing
5. Longma

However, the Memory Board can permit controlled free selection where no chronology conflict exists.

## What Completion Changes

When all required memory arcs are complete:

- `MEMORY_CAMPAIGN_COMPLETE = true`
- every protagonist's core origin is considered understood by the player;
- relationship baselines are upgraded;
- selected character-linked combo skills unlock;
- additional camp conversations become available;
- the next major shared pilgrimage chapter unlocks.

The global world timeline does **not** move backward during memories.

## Anti-Repetition Rule

Memories should reveal context, not reproduce entire chapters that the player already completed.

A memory should usually be shorter than a full major chapter and should answer one question such as:

- Why does Wukong distrust Heaven?
- Why does Tang tolerate danger rather than retreat?
- Why does Bajie joke when embarrassed?
- Why does Wujing rarely complain?
- Why does Longma react strongly to hierarchy?

## Design Goal

The Memory Campaign is the game's emotional bridge between:

`I recruited these characters`

and

`I understand why these five people are capable of completing this journey together.`
