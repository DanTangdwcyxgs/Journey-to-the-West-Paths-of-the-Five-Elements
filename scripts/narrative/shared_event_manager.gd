class_name SharedEventManager
extends RefCounted

const DATA_PATH := "res://data/narrative/shared_events.json"
var events: Dictionary = {}

func _init() -> void:
	_load()

func _load() -> void:
	events.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var raw := parsed.get("events", {})
		if raw is Dictionary:
			for key in raw.keys():
				if raw[key] is Dictionary:
					events[str(key)] = raw[key].duplicate(true)

func get_event(event_id: String) -> Dictionary:
	return events.get(event_id, {}).duplicate(true)

func has_event(event_id: String) -> bool:
	return not get_event(event_id).is_empty()

func apply_choice(manager: NarrativeManager, chapter_id: String, choice_id: String) -> bool:
	if manager == null or chapter_id == "" or choice_id == "":
		return false
	var event := get_event(chapter_id)
	if event.is_empty():
		return false
	for choice in event.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			manager.state.origin_choices["SHARED:%s" % chapter_id] = choice_id
			return true
	return false

func get_choice(manager: NarrativeManager, chapter_id: String) -> String:
	if manager == null:
		return ""
	return str(manager.state.origin_choices.get("SHARED:%s" % chapter_id, ""))
