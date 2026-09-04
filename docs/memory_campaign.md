# Memory Campaign: Character Routes Unlock at Recruitment

## Core Rule

**A character's personal route becomes available for replay/remembrance as soon as that character is encountered and recruited or otherwise becomes part of the player's current party journey. It does not wait for all five characters to be assembled.**

This is a foundational structural rule of the project and is directly inspired by the character-story structure of classic chapter-based JRPGs.

The player is always moving through the shared Journey to the West timeline while individual character histories become available at the moment that character enters the player's story.

The intended experience is:

```text
Choose a starting hero
        ↓
Play that hero's origin
        ↓
Reach a canonical encounter
        ↓
A new character joins / becomes relevant
        ↓
That character's personal story becomes available
        ↓
Player may enter that character's story
        ↓
Return to the current shared timeline
        ↓
Continue pilgrimage
        ↓
Meet the next character
        ↓
Unlock the next character's story
```

There is **no single five-person Memory Campaign gate**.

---

# 1. The Octopath-Like Story Loop

The game should recreate the feeling of progressively discovering the biographies of party members.

### Example: Starting as Tang Sanzang

```text
Tang origin
    ↓
Five Elements Mountain
    ↓
Sun Wukong joins
    ↓
[Wukong personal route unlocked]
    ↓
Player may play Wukong's origin/history
    ↓
Return to Tang + Wukong shared journey
    ↓
Eagle Sorrow Stream / Bai Longma
    ↓
[Longma personal route unlocked]
    ↓
Return to current journey
    ↓
Gaojiazhuang / Zhu Bajie
    ↓
[Bajie personal route unlocked]
    ↓
Return to current journey
    ↓
Flowing Sands River / Sha Wujing
    ↓
[Wujing personal route unlocked]
    ↓
Continue shared pilgrimage
```

The key feeling is:

> **I meet a person, I gain that person, and now I have the opportunity to understand who that person was.**

---

# 2. What “Unlocking a Character Story” Means

Unlocking a character story does not necessarily mean the entire character origin must become available in one uninterrupted block.

Instead, recruitment creates an **availability window** for that character's historical route.

The route can contain:

- full origin chapters;
- short memory chapters;
- perspective chapters;
- flashbacks;
- optional character quests;
- relationship scenes;
- historical battles.

The player may return to the shared journey at any time unless a specific chapter is marked as mandatory.

---

# 3. Three Narrative Time Layers

The save system must distinguish three timelines.

## A. Historical Timeline

When the remembered event actually happened in the character's life.

## B. Current World Timeline

Where the shared pilgrimage currently is.

## C. Player Progress

Which historical chapters the player has personally completed.

Example:

```text
Current World:
  AFTER_BAJIE_RECRUITED

Wukong historical chapters:
  COMPLETE

Tang historical chapters:
  PARTIAL

Bajie historical chapters:
  AVAILABLE

Wujing historical chapters:
  LOCKED

Longma historical chapters:
  AVAILABLE
```

This is the correct model for allowing character stories to unlock progressively.

---

# 4. Unlock Rules by Recruitment Stage

## Before Meeting a Character

The player may know rumors, legends or indirect references to that character, but the character's full personal route remains locked.

Example:

Before meeting Bajie, the player may hear stories about a pig demon at Gaojiazhuang, but cannot freely enter Bajie's personal campaign.

## At First Canonical Encounter

The character route becomes available according to the encounter's unlock flag.

For major recruits this normally happens at the recruitment event.

Example:

```text
ZHU_BAJIE_RECRUITED
        ↓
unlock route BAJIE
```

## After Unlock

The player's chapter menu can show:

```text
Bajie — Story Available

[Continue Shared Journey]
[Remember Bajie's Past]
```

The game may also surface the route through camp dialogue or chapter selection rather than a literal menu button.

---

# 5. Route Availability Is Not the Same as Route Completion

This distinction is important.

A character may have ten historical chapters while only the first three are safe to reveal when they are recruited.

Therefore every historical chapter has its own:

- `historical_timeline_index`
- `unlock_milestone`
- `spoiler_safe_until`
- `route_sequence`
- `required_previous_chapters`

Example:

```text
Bajie recruited
    ↓
BAJIE_MEMORY_01 available
BAJIE_MEMORY_02 available
BAJIE_MEMORY_03 available

Later global milestone:
WHITE_BONE_DEMON_COMPLETE
    ↓
BAJIE_MEMORY_04 unlocked
```

This preserves story discovery and prevents the player from seeing information that the shared journey has not earned yet.

---

# 6. Starting Character Rule

The character chosen at New Game remains the player's primary initial lens.

However, once another character joins, that new character's historical route becomes part of the same save file.

### Example: Start as Wukong

```text
Wukong origin
→ Five Elements Mountain
→ Tang / Wukong shared story
→ Longma encounter
→ Longma route unlocked
→ Gaojiazhuang
→ Bajie route unlocked
→ Flowing Sands River
→ Wujing route unlocked
```

The player does not need to wait for the full five-person party before remembering Longma, Bajie or Wujing.

### Example: Start as Tang

```text
Tang origin
→ Wukong recruited
→ Wukong route unlocked
→ shared duo journey
→ Longma joins
→ Longma route unlocked
→ shared journey
→ Bajie joins
→ Bajie route unlocked
```

The first-person perspective changes the opening, but the recruitment rhythm remains fixed.

---

# 7. Returning From a Personal Route

A historical route is a temporary narrative excursion.

When the player completes or exits it:

1. the world returns to the exact previous shared timeline;
2. no historical event is re-applied to the world;
3. current party composition is preserved;
4. current quest state is preserved;
5. any permanent rewards from the memory are committed normally;
6. the player resumes the shared Journey.

The memory route never advances the world into its historical date.

---

# 8. Mandatory vs Optional Personal Chapters

Each recruited character route can contain two kinds of content.

## Required Character Chapter

Used when understanding the character is necessary to comprehend a major upcoming shared event.

Example:

A short Wukong chapter about Heaven may become required before a major celestial encounter.

## Optional Character Chapter

Adds depth, rewards, relationship development or gameplay mastery but does not block the main story.

This allows the main campaign to preserve a strong television-like pace without forcing every player through every biography scene.

---

# 9. The Party Is Always the Current Point of the Story

The player should never feel that remembering someone means leaving the current game behind for a completely separate campaign.

The structure is:

```text
CURRENT JOURNEY
      ↓
CHARACTER BECOMES RELEVANT
      ↓
CHARACTER STORY UNLOCKS
      ↓
OPTIONAL / REQUIRED HISTORICAL CHAPTER
      ↓
RETURN TO CURRENT JOURNEY
```

The emotional purpose is to deepen the party at the exact moment that the player becomes interested in that person.

---

# 10. Relationship With Shared Journey

Character memories should frequently be triggered by present-day context.

Examples:

### Wukong

Party meets a celestial official.

→ Wukong memory about Bimawen / Heaven becomes available.

### Bajie

Party reaches a place associated with the Heavenly Court.

→ Tianpeng memory becomes available.

### Wujing

Party crosses a major river.

→ Flowing Sands memory becomes available.

### Longma

Party meets a Dragon Court emissary.

→ Longma's Dragon Prince memory becomes available.

### Tang

Party encounters a Buddhist scholar or temple.

→ Tang's monastery / pilgrimage memory becomes available.

This is preferable to dumping all historical chapters into a menu at once.

---

# 11. No Five-Person Gate

The following previous structure is explicitly rejected:

```text
Recruit all five
    ↓
Unlock everyone's memories
```

That is **not** the intended game structure.

The correct structure is:

```text
Meet Wukong
    ↓
Unlock Wukong memories

Meet Longma
    ↓
Unlock Longma memories

Meet Bajie
    ↓
Unlock Bajie memories

Meet Wujing
    ↓
Unlock Wujing memories
```

The only thing that happens at `PARTY_FULL` is that the five-person shared-party gameplay and ensemble relationship layer becomes complete.

It does not unlock the basic existence of character memories.

---

# 12. Why This Structure Matters

This structure creates a constantly renewing narrative reward loop:

```text
Travel
→ meet someone
→ recruit them
→ understand them
→ use their new gameplay identity
→ encounter their past in the present world
→ deepen relationship
→ travel onward
```

Every recruitment therefore delivers three rewards at once:

1. a new playable combat identity;
2. a new personal story route;
3. a new relationship perspective.

This is one of the central reasons the five-character structure should feel like a JRPG rather than a linear visual retelling.

---

# 13. Full Convergence Still Has a Purpose

`PARTY_FULL` remains important, but it is **not** the memory unlock gate.

Once all five are together, the game should introduce an ensemble layer:

- large camp conversations;
- group relationship scenes;
- five-way arguments and humor;
- combination skills;
- shared quests;
- group memories;
- the first major problem requiring all five identities.

The player's earlier personal-story experiences now pay off because the player already knows why each character reacts the way they do.

So the progression becomes:

```text
Individual story
→ encounter
→ recruit
→ unlock that person's past
→ growing party
→ new recruit
→ unlock their past
→ growing party
→ full party
→ ensemble story
→ shared pilgrimage
```

---

# 14. Data Model Requirements

`CharacterRouteState`

```text
character_id
is_unlocked
origin_available_until
completed_chapters
available_chapters
completed_memory_chapters
```

`MemoryChapterDefinition`

```text
id
character_id
historical_timeline_index
unlock_milestone
spoiler_safe_until
required_previous_memory_ids
chapter_type
map_id
encounter_ids
completion_rewards
present_day_trigger_ids
```

`RecruitmentEvent`

```text
character_id
trigger_milestone
route_unlock_ids
party_change
shared_timeline_result
```

The important property is that `route_unlock_ids` are emitted by the recruitment event itself.

---

# 15. Canonical Examples

## Tang Route

```text
Start as Tang
↓
Tang origin
↓
Meet Wukong
↓
WUKONG route unlocked
↓
Play Wukong memories
↓
Return to Tang/Wukong journey
```

## Wukong Route

```text
Start as Wukong
↓
Wukong origin
↓
Five Elements Mountain
↓
Tang route context becomes relevant
↓
Shared journey begins
```

## Bajie Route

```text
Start or encounter Bajie
↓
Gaojiazhuang recruitment
↓
BAJIE route unlocked immediately
↓
Play Tianpeng / fall / mortal-life memories
↓
Return to current party
```

## Full Party

```text
Wukong + Tang + Longma + Bajie + Wujing
↓
PARTY_FULL
↓
Ensemble Chapter
↓
Shared pilgrimage
```

No additional memory unlock gate exists here.

---

# 16. Golden Rule

> **When the player meets a person, that person's story becomes available.**
>
> **When the player returns to the road, the world continues exactly where it left off.**
>
> **When the five finally gather, the story becomes an ensemble—not a biography menu.**
