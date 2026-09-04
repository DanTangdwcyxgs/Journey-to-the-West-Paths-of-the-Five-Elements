# Narrative State Model

The story system must track several independent dimensions. In particular, **character-story availability is tied to recruitment/encounter progression, not to `PARTY_FULL`.**

## 1. Starting Lens

`starting_character_id`

The protagonist chosen at New Game. This determines the first origin route and should never be overwritten.

## 2. Global Timeline

`current_timeline_index`

Represents the world's canonical chronological position. Shared events advance this value.

## 3. Character Route Progress

Each character has an independent route state:

```text
character_id
route_status
completed_origin_chapters
available_story_chapters
completed_memory_chapters
recruitment_status
```

`route_status` may be:

- `LOCKED`
- `UNLOCKED`
- `IN_PROGRESS`
- `COMPLETE`

## 4. Route Unlock Rule

A character's route becomes available when the player reaches that character's canonical encounter/recruitment point, or when the character is the starting protagonist.

The route does **not** wait for the other four protagonists.

Example:

```text
Tang selected
→ Five Elements Mountain
→ Wukong recruited
→ Wukong route_status = UNLOCKED
```

Later:

```text
Gaojiazhuang
→ Bajie recruited
→ Bajie route_status = UNLOCKED
```

And later:

```text
Flowing Sands River
→ Wujing recruited
→ Wujing route_status = UNLOCKED
```

## 5. Story Chapter Availability

A chapter is available when all predicates are true:

```text
STARTING_CHARACTER OR character.route_status != LOCKED
AND current_timeline_index >= chapter.timeline_gate
AND all prerequisites are complete
AND previous chapter in route is complete when sequential progression is required
AND spoiler guards are satisfied
```

A character route can therefore be unlocked while only a **safe portion** of that route is currently playable.

## 6. Historical / Memory Chapter Rule

Historical chapters have their own timeline.

```text
is_historical == true
AND character.route_status != LOCKED
AND historical_timeline_index <= spoiler_safe_limit
AND historical prerequisites are complete
```

A historical chapter temporarily changes the player's narrative perspective, not the current world timeline.

When it ends:

- restore the previous shared timeline;
- restore the current party state;
- preserve completed memory progress;
- preserve any permanent rewards;
- resume the shared chapter exactly where the player left it.

## 7. Immediate Character-Story Unlock

Recruitment should emit a route unlock event:

```text
RecruitmentEvent
    ↓
unlock_character_route(character_id)
    ↓
evaluate available historical chapters
    ↓
present newly available story content
```

This should happen at the end of the recruitment event or at the explicitly defined narrative handoff point.

## 8. Example: Starting as Tang

A representative save state can look like:

```text
starting_character = TANG
current_timeline = AFTER_WUKONG_RECRUITED

TANG.route_status = IN_PROGRESS
WUKONG.route_status = UNLOCKED
LONGMA.route_status = LOCKED
BAJIE.route_status = LOCKED
WUJING.route_status = LOCKED
```

The player can:

```text
Continue Tang + Wukong journey
OR
Enter an available Wukong historical chapter
```

After Longma becomes part of the pilgrimage:

```text
LONGMA.route_status = UNLOCKED
```

The Longma story becomes available without waiting for Bajie or Wujing.

## 9. Example: Starting as Wukong

```text
Wukong origin
→ Wukong imprisoned
→ Tang journey converges
→ Wukong recruited
→ Tang route context becomes available
```

The same narrative system applies regardless of which protagonist was selected first.

## 10. Recruitment Rule

Recruitment is an irreversible world milestone in the normal campaign.

A character cannot be removed from the canonical party timeline simply because the player started with another protagonist.

## 11. `PARTY_FULL` Rule

`PARTY_FULL` is **not** a story-route unlock gate.

It means:

- all five protagonists are available to the main party;
- full formation gameplay is unlocked;
- five-person relationship interactions are available;
- ensemble chapters can begin;
- the main story can transition into the full shared-pilgrimage phase.

It must not be used as the condition for first unlocking a character's personal history.

## 12. Convergence Rule

When `PARTY_FULL` becomes true, the campaign may enter the ensemble/shared-journey state.

From this point:

- new main-story chapters are shared by default;
- already-unlocked character routes remain available;
- new character memories can continue to unlock from world milestones;
- optional relationship scenes may branch, but must not fork the canonical world timeline;
- all five protagonists remain available unless a story event explicitly changes temporary battle availability.

## 13. Save Compatibility

Milestone IDs, route IDs, chapter IDs and historical chapter IDs are stable content identifiers.

Changing display text is safe. Renaming or deleting referenced IDs is a save-breaking change and requires migration.

## 14. Design Principle

The player should repeatedly experience this loop:

```text
Meet a person
→ gain access to that person's story
→ learn more about them
→ continue the current journey
→ meet the next person
→ gain the next story
```

This is a core narrative mechanic, not optional flavor.