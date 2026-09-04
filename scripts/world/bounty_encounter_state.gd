class_name BountyEncounterState
extends RefCounted

## Lightweight handoff between world-map and battle scenes.
## This is intentionally transient: the canonical save remains NarrativeState.
const PATH := "user://active_bounty.json"

static func start(bounty_id: String) -> bool:
	if bounty_id == "":
		return false
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"bounty_id": bounty_id}))
	return true

static func get_active() -> String:
	if not FileAccess.file_exists(PATH):
		return ""
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return ""
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		return str(data.get("bounty_id", ""))
	return ""

static func clear() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
