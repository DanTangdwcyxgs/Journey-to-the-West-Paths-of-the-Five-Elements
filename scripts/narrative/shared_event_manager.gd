class_name SharedEventManager
extends RefCounted

const DATA_PATH := "res://data/narrative/shared_events.json"
var definitions: Dictionary = {}

func _init() -> void:
	_load()

func _load() -> void:
	definitions.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var raw := parsed.get("events", {})
		if raw is Dictionary:
			for key in raw.keys():
				if raw[key] is Dictionary:
					var data: Dictionary = raw[key].duplicate(true)
					if not data.has("id"):
						data["id"] = str(key)
					definitions[str(key)] = data

func get_event(event_id: String) -> Dictionary:
	return definitions.get(event_id, {}).duplicate(true)

func get_definition(event_id: String) -> EventDefinition:
	return EventDefinition.new(get_event(event_id))

func has_event(event_id: String) -> bool:
	return not get_event(event_id).is_empty()

func apply_choice(manager: NarrativeManager, event_id: String, choice_id: String) -> bool:
	if manager == null or event_id == "" or choice_id == "":
		return false
	var event := get_definition(event_id)
	return EventRuntime.apply_choice(event, manager, choice_id, "SHARED")

func get_choice(manager: NarrativeManager, event_id: String) -> String:
	if manager == null:
		return ""
	return manager.state.get_shared_choice(event_id)
