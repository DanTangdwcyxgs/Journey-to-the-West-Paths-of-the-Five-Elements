class_name EventSequenceManager
extends RefCounted

## Data-driven loader for executable narrative sequences.
## Content authors edit JSON; callers consume EventSequenceDefinition.

const PATH := "res://data/narrative/event_sequences.json"
static var _sequences: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	for item in parsed.get("sequences", []):
		if not item is Dictionary:
			continue
		var definition := EventSequenceDefinition.new(item)
		if not definition.is_empty() and definition.validate().get("valid", false):
			_sequences[definition.get_id()] = definition

static func get_definition(sequence_id: String) -> EventSequenceDefinition:
	_ensure_loaded()
	return _sequences.get(sequence_id, null)

static func get_all_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for id in _sequences.keys():
		ids.append(str(id))
	return ids

static func has_sequence(sequence_id: String) -> bool:
	return get_definition(sequence_id) != null
