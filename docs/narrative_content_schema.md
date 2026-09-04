# Narrative Content Schema

This document defines the minimum data model needed to turn the five-character story plan into editable game content.

## CharacterDefinition

```text
id
name
route_id
combat_role
core_theme
origin_chapter_ids
recruitment_event_id
post_recruitment_chapter_ids
starting_location_id
```

## ChapterDefinition

```text
id
route_id
character_id
chapter_type
sequence_index
historical_timeline_index
timeline_gate
prerequisites
scene_ids
map_id
encounter_ids
boss_encounter_id
reward_ids
completion_milestone
is_origin
is_flashback
is_shared
```

### `chapter_type`

Allowed values:

- `ORIGIN`
- `RECRUITMENT`
- `SHARED`
- `PERSPECTIVE`
- `MAJOR_TRIAL`
- `INTERLUDE`
- `SIDE_STORY`

## WorldMilestone

```text
id
chronological_index
title
description
owner_chapter_id
```

`chronological_index` is the source of truth for the shared world timeline.

## RecruitmentEvent

```text
id
character_id
trigger_milestone
scene_id
resulting_party_change
unlock_ids
```

Recruitment must be a deterministic event. A UI button must never directly set a character as recruited.

## SceneDefinition

```text
id
chapter_id
scene_type
participants
dialogue_id
camera_profile
music_id
flags
```

## EncounterDefinition

```text
id
chapter_id
enemy_group_id
battle_modifier_ids
recommended_level
victory_milestone
defeat_behavior
```

## SaveNarrativeState

```text
starting_character
current_global_timeline
completed_chapters
completed_milestones
recruited_characters
route_progress
unlocked_chapters
relationship_values
active_flashbacks
```

## Unlock Algorithm

When evaluating a chapter:

1. If it is an origin chapter, allow it when selected as the starting route or explicitly unlocked as historical content.
2. Otherwise verify the chapter's `timeline_gate` against `current_global_timeline`.
3. Verify all `prerequisites`.
4. Verify the previous route chapter when sequential progression is required.
5. Verify spoiler safety for flashbacks.
6. Return the chapter as available without mutating narrative state.

When the chapter completes, its completion milestone is recorded and any recruitment event is resolved by the narrative system.

## Important Separation

The content schema describes **what happens**. The combat engine describes **how battles resolve**. Presentation scenes describe **how the event looks and sounds**.

No content asset should contain direct damage formulas or UI manipulation code.

## Example: Wukong Meets Five Elements Mountain

```text
ChapterDefinition
  id: WUKONG_15_FIVE_ELEMENTS
  route_id: WUKONG
  character_id: WUKONG
  chapter_type: RECRUITMENT
  historical_timeline_index: T80
  timeline_gate: WUKONG_IMPRISONED
  scene_ids: [WUKONG_SEAL_SCENE]
  completion_milestone: WUKONG_ORIGIN_COMPLETE
```

The Tang route can reference the same world milestone with a different chapter owner/perspective, but there must remain one canonical gameplay event.
