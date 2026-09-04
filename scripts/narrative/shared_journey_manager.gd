class_name SharedJourneyManager
extends RefCounted

## Canonical shared-journey progression. World chronology only moves forward.
## Recruitment events are idempotent so different starting routes can converge safely.

const CHAPTERS := [
	{"id":"SHARED-01-FIVE-ELEMENTS","title":"五行山","timeline":100,"required":"WUKONG_RECRUITED","recruit":[],"next":"SHARED-02-EARLY-PILGRIMAGE"},
	{"id":"SHARED-02-EARLY-PILGRIMAGE","title":"师徒初行","timeline":105,"required":"WUKONG_RECRUITED","recruit":[],"next":"SHARED-03-EAGLE-SORROW"},
	{"id":"SHARED-03-EAGLE-SORROW","title":"鹰愁涧","timeline":110,"required":"WUKONG_RECRUITED","recruit":[{"character":"LONGMA","memories":["LONGMA-01","LONGMA-02"]}],"next":"SHARED-04-EARLY-DEMON-TALES"},
	{"id":"SHARED-04-EARLY-DEMON-TALES","title":"黑风山与早期妖患","timeline":120,"required":"BAI_LONGMA_RECRUITED","recruit":[],"next":"SHARED-05-GAOJIAZHUANG"},
	{"id":"SHARED-05-GAOJIAZHUANG","title":"高老庄","timeline":130,"required":"BAI_LONGMA_RECRUITED","recruit":[{"character":"BAJIE","memories":["BAJIE-01","BAJIE-02"]}],"next":"SHARED-06-FOUR-PERSON-JOURNEY"},
	{"id":"SHARED-06-FOUR-PERSON-JOURNEY","title":"四人西行","timeline":140,"required":"ZHU_BAJIE_RECRUITED","recruit":[],"next":"SHARED-07-FLOWING-SANDS"},
	{"id":"SHARED-07-FLOWING-SANDS","title":"流沙河","timeline":150,"required":"ZHU_BAJIE_RECRUITED","recruit":[{"character":"WUJING","memories":["WUJING-01","WUJING-02"]}],"next":"SHARED-08-PARTY-FULL"},
	{"id":"SHARED-08-PARTY-FULL","title":"五人归队","timeline":160,"required":"SHA_WUJING_RECRUITED","recruit":[],"next":"SHARED-09-FULL-PILGRIMAGE"},
	{"id":"SHARED-09-FULL-PILGRIMAGE","title":"完整西行","timeline":170,"required":"PARTY_FULL","recruit":[],"next":""},
]

static func get_chapter(chapter_id: String) -> Dictionary:
	for chapter in CHAPTERS:
		if str(chapter.get("id", "")) == chapter_id:
			return chapter.duplicate(true)
	return {}

static func first_chapter_for_state(state: NarrativeState) -> Dictionary:
	if state.current_shared_chapter != "":
		return get_chapter(state.current_shared_chapter)
	for chapter in CHAPTERS:
		if _requirements_met(chapter, state):
			return chapter.duplicate(true)
	return {}

static func can_enter(chapter_id: String, state: NarrativeState) -> bool:
	var chapter := get_chapter(chapter_id)
	if chapter.is_empty():
		return false
	if chapter_id in state.completed_shared_chapters:
		return false
	return _requirements_met(chapter, state)

static func complete(chapter_id: String, manager: NarrativeManager) -> bool:
	var chapter := get_chapter(chapter_id)
	if chapter.is_empty() or not can_enter(chapter_id, manager.state):
		return false

	manager.complete_chapter(chapter_id, true)
	manager.advance_world_milestone(str(chapter.get("id", "")), int(chapter.get("timeline", 0)))
	_apply_recruitment_events(chapter, manager)

	var next_id := str(chapter.get("next", ""))
	if next_id != "":
		manager.set_shared_chapter(next_id)
	else:
		manager.set_shared_chapter(chapter_id)
	manager.save()
	return true

static func next_for_state(state: NarrativeState) -> Dictionary:
	var current := get_chapter(state.current_shared_chapter)
	if current.is_empty():
		return first_chapter_for_state(state)
	var next_id := str(current.get("next", ""))
	if next_id == "":
		return current
	return get_chapter(next_id)

static func _apply_recruitment_events(chapter: Dictionary, manager: NarrativeManager) -> void:
	var events: Array = chapter.get("recruit", [])
	for event in events:
		if not event is Dictionary:
			continue
		var character_id := str(event.get("character", ""))
		if character_id == "":
			continue
		var memories: Array[String] = []
		for memory_id in event.get("memories", []):
			memories.append(str(memory_id))
		manager.encounter_character(character_id, memories)

static func _requirements_met(chapter: Dictionary, state: NarrativeState) -> bool:
	var required := str(chapter.get("required", ""))
	match required:
		"WUKONG_RECRUITED":
			return "WUKONG" in state.recruited_characters
		"BAI_LONGMA_RECRUITED":
			return "LONGMA" in state.recruited_characters
		"ZHU_BAJIE_RECRUITED":
			return "BAJIE" in state.recruited_characters
		"SHA_WUJING_RECRUITED":
			return "WUJING" in state.recruited_characters
		"PARTY_FULL":
			return state.recruited_characters.size() >= NarrativeState.CHARACTER_IDS.size()
	return true
