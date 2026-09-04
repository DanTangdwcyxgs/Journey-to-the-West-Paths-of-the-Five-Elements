class_name NarrativeSave
extends RefCounted

## Minimal file-backed persistence for NarrativeState.
## Uses a dedicated user:// slot so narrative progress survives scene changes and restarts.

const SAVE_PATH := "user://narrative_slot_1.json"
const VERSION := 1

static func save_state(state: NarrativeState, path: String = SAVE_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	var payload := {
		"version": VERSION,
		"narrative": state.to_dict(),
	}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true

static func load_state(path: String = SAVE_PATH) -> NarrativeState:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		return null
	var narrative_data = parsed.get("narrative", null)
	if not narrative_data is Dictionary:
		return null
	return NarrativeState.from_dict(narrative_data)

static func has_save(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)

static func delete_save(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(path) == OK
