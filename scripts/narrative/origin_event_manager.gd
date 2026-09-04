class_name OriginEventManager
extends RefCounted

const DATA_PATH := "res://data/narrative/origin_events.json"

var definitions: Dictionary = {}

func _init() -> void:
	load_definitions()

func load_definitions() -> void:
	definitions.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		definitions = parsed.get("events", {}).duplicate(true)

func get_event(chapter_id: String) -> Dictionary:
	return definitions.get(chapter_id, {}).duplicate(true)

func has_event(chapter_id: String) -> bool:
	return not get_event(chapter_id).is_empty()

func get_choice(chapter_id: String, choice_id: String) -> Dictionary:
	var event := get_event(chapter_id)
	if event.is_empty():
		return {}
	for choice in event.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			return choice.duplicate(true)
	return {}

func get_choice_effects(chapter_id: String, choice_id: String) -> Dictionary:
	return get_choice(chapter_id, choice_id).get("effects", {}).duplicate(true)

func apply_choice(narrative: NarrativeManager, chapter_id: String, choice_id: String) -> bool:
	if narrative == null or chapter_id == "" or choice_id == "":
		return false
	if narrative.state.get_origin_choice(chapter_id) != "":
		return false
	var event := get_event(chapter_id)
	for choice in event.get("choices", []):
		if str(choice.get("id", "")) != choice_id:
			continue
		_apply_effects(narrative, chapter_id, choice_id, choice.get("effects", {}))
		return true
	return false

func _apply_effects(narrative: NarrativeManager, chapter_id: String, choice_id: String, effects: Variant) -> void:
	var data: Dictionary = effects if effects is Dictionary else {}
	narrative.state.record_origin_choice(chapter_id, choice_id)
	var relationships: Dictionary = data.get("relationship_values", {})
	for key in relationships.keys():
		var id := str(key)
		narrative.state.relationship_values[id] = int(narrative.state.relationship_values.get(id, 0)) + int(relationships[key])
	var milestones: Array = data.get("milestones", [])
	for milestone in milestones:
		var marker := str(milestone)
		if marker != "" and marker not in narrative.state.completed_milestones:
			narrative.state.completed_milestones.append(marker)
