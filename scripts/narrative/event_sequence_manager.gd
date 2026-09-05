class_name EventSequenceManager
extends RefCounted

## Data-driven loader for executable narrative sequences.
## Content authors edit JSON; callers consume EventSequenceDefinition.
## Invalid cross-references are rejected before a sequence enters the runtime catalog.

const PATH := "res://data/narrative/event_sequences.json"
const ORIGIN_PATH := "res://data/narrative/event_sequences_origin.json"
static var _sequences: Dictionary = {}
static var _errors: Array[String] = []
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_sequences.clear()
	_errors.clear()
	_load_catalog(PATH)
	_load_catalog(ORIGIN_PATH)

static func _load_catalog(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_errors.append("cannot open %s" % path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_errors.append("invalid JSON root in %s" % path)
		return
	for item in parsed.get("sequences", []):
		if not item is Dictionary:
			_errors.append("sequence entry is not an object in %s" % path)
			continue
		var definition := EventSequenceDefinition.new(item)
		var validation := EventSequenceValidator.validate(definition)
		if validation.get("valid", false):
			var sequence_id := definition.get_id()
			if _sequences.has(sequence_id):
				_errors.append("duplicate sequence id: %s" % sequence_id)
			else:
				_sequences[sequence_id] = definition
		else:
			for error in validation.get("errors", []):
				_errors.append("%s: %s" % [definition.get_id(), str(error)])

static func get_definition(sequence_id: String) -> EventSequenceDefinition:
	_ensure_loaded()
	return _sequences.get(sequence_id, null)

static func get_all_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for id in _sequences.keys():
		ids.append(str(id))
	return ids

static func get_load_errors() -> Array[String]:
	_ensure_loaded()
	return _errors.duplicate()

static func has_sequence(sequence_id: String) -> bool:
	return get_definition(sequence_id) != null
