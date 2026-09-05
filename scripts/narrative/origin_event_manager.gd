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

func get_definition(chapter_id: String) -> EventDefinition:
	return EventDefinition.new(get_event(chapter_id))

func has_event(chapter_id: String) -> bool:
	return not get_event(chapter_id).is_empty()

func get_choice(chapter_id: String, choice_id: String) -> Dictionary:
	return get_definition(chapter_id).get_choice(choice_id)

func get_choice_effects(chapter_id: String, choice_id: String) -> Dictionary:
	return get_choice(chapter_id, choice_id).get("effects", {}).duplicate(true)

func apply_choice(narrative: NarrativeManager, chapter_id: String, choice_id: String) -> bool:
	if narrative == null or chapter_id == "" or choice_id == "":
		return false
	var event := get_definition(chapter_id)
	return EventRuntime.apply_choice(event, narrative, choice_id, "ORIGIN")
