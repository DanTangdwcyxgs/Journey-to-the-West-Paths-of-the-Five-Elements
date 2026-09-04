# Narrative State Model

The story system must track **three independent dimensions**:

## 1. Starting Lens

`starting_character_id`

The protagonist chosen at New Game. This determines the first origin route and should never be overwritten.

## 2. Global Timeline

`current_timeline_index`

Represents the world's canonical chronological position. Shared events advance this value.

## 3. Character Route Progress

Per-character route state:

```text
character_id
completed_origin_chapters
completed_memory_chapters
recruitment_status
```

These values must be independent.

Example:

```text
starting_character = WUKONG
current_timeline = WUKONG_IMPRISONED
WUKONG.origin_complete = true
TANG.origin_complete = false
BAJIE.origin_complete = false
WUJING.origin_complete = false
LONGMA.origin_complete = false
```

After Tang reaches Five Elements Mountain:

```text
current_timeline = WUKONG_RECRUITED
after_event:
  WUKONG.recruitment_status = recruited
```

## Unlock Evaluation

A chapter is available when all predicates are true:

```text
is_origin OR character.recruitment_status == recruited
AND current_timeline_index >= chapter.timeline_gate
AND all prerequisites are complete
AND previous chapter in route is complete
```

For memory chapters:

```text
is_memory == true
AND historical_timeline_index <= current_timeline_index
AND memory prerequisites are complete
```

## Recruitment Rule

Recruitment is an irreversible world milestone in the normal campaign.

A character cannot be removed from the canonical party timeline simply because the player started with another protagonist.

## Convergence Rule

When `PARTY_FULL` becomes true, the campaign enters `SHARED_JOURNEY` state.

From this point:

- new main-story chapters are shared by default;
- character-specific stories are represented by memory/perspective chapters;
- optional relationship scenes may branch, but must not fork the canonical world timeline;
- all five protagonists remain available unless a story event explicitly changes their temporary battle availability.

## Save Compatibility

Milestone IDs and chapter IDs are stable content identifiers. Changing display text is safe; renaming IDs is a save-breaking change and requires migration.
