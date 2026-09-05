class_name ChapterRuntime
extends RefCounted

## Shared chapter execution contract.
## This first version is intentionally conservative: it standardizes discovery,
## validation and routing before full scene/event execution is migrated here.

static func from_data(data: Dictionary) -> ChapterDefinition:
	return ChapterDefinition.new(data)

static func can_enter(chapter: ChapterDefinition, state: NarrativeState) -> bool:
	if chapter == null or chapter.is_empty() or state == null:
		return false
	if chapter.get_id() in state.completed_shared_chapters or chapter.get_id() in state.completed_chapters:
		return false
	if not _requirements_met(chapter, state):
		return false
	if not _prerequisites_met(chapter, state):
		return false
	return true

static func next_id(chapter: ChapterDefinition) -> String:
	if chapter == null:
		return ""
	return chapter.get_next_id()

static func destination(chapter: ChapterDefinition) -> Dictionary:
	if chapter == null or chapter.is_empty():
		return {}
	if chapter.is_combat():
		return {
			"kind": "battle",
			"encounter_id": chapter.get_encounter_id(),
			"chapter_id": chapter.get_id(),
		}
	if not chapter.get_event_id().is_empty():
		return {
			"kind": "event",
			"event_id": chapter.get_event_id(),
			"chapter_id": chapter.get_id(),
		}
	return {
		"kind": "chapter",
		"chapter_id": chapter.get_id(),
	}

static func _prerequisites_met(chapter: ChapterDefinition, state: NarrativeState) -> bool:
	for prerequisite in chapter.get_prerequisites():
		var prerequisite_id := str(prerequisite)
		if prerequisite_id.is_empty():
			continue
		if prerequisite_id not in state.completed_chapters and prerequisite_id not in state.completed_shared_chapters:
			return false
	return true

static func _requirements_met(chapter: ChapterDefinition, state: NarrativeState) -> bool:
	var required := chapter.get_required()
	match required:
		"WUKONG_RECRUITED": return "WUKONG" in state.recruited_characters
		"BAI_LONGMA_RECRUITED": return "LONGMA" in state.recruited_characters
		"ZHU_BAJIE_RECRUITED": return "BAJIE" in state.recruited_characters
		"SHA_WUJING_RECRUITED": return "WUJING" in state.recruited_characters
		"PARTY_FULL": return state.recruited_characters.size() >= NarrativeState.CHARACTER_IDS.size()
	return true
