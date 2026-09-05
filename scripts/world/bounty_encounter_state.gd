class_name BountyEncounterState
extends RefCounted

## Lightweight handoff between exploration/narrative scenes and battle scenes.
## The canonical narrative save remains NarrativeState.
const PATH := "user://active_bounty.json"
const RESUME_PATH := "user://pending_event_resume.json"

static func start(bounty_id: String, source_stage_id: String = "") -> bool:
	return start_encounter("bounty", bounty_id, source_stage_id)

static func start_encounter(encounter_type: String, encounter_id: String, source_stage_id: String = "", source_chapter_id: String = "", source_route_id: String = "", extra: Dictionary = {}) -> bool:
	if encounter_id == "":
		return false
	var payload := {
		"encounter_type": encounter_type,
		"encounter_id": encounter_id,
		"bounty_id": encounter_id if encounter_type == "bounty" else "",
		"source_stage_id": source_stage_id,
		"source_chapter_id": source_chapter_id,
		"source_route_id": source_route_id,
	}
	for key in extra.keys():
		payload[str(key)] = extra[key]
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	return true

static func start_narrative_encounter(encounter_id: String, chapter_id: String, route_id: String, extra: Dictionary = {}) -> bool:
	if route_id == "SHARED_JOURNEY":
		var shared_chapter_id := chapter_id.trim_prefix("shared:")
		return start_shared_encounter(encounter_id, shared_chapter_id, extra)
	return start_encounter("origin", encounter_id, "", chapter_id, route_id, extra)

static func start_shared_encounter(encounter_id: String, chapter_id: String, extra: Dictionary = {}) -> bool:
	return start_encounter("shared", encounter_id, "", chapter_id, "SHARED_JOURNEY", extra)

static func get_active() -> String:
	var record := get_active_record()
	return str(record.get("encounter_id", record.get("bounty_id", "")))

static func get_active_record() -> Dictionary:
	if FileAccess.file_exists(PATH):
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file != null:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				return data
	if not FileAccess.file_exists(RESUME_PATH):
		return {}
	var resume_file := FileAccess.open(RESUME_PATH, FileAccess.READ)
	if resume_file == null:
		return {}
	var resume_data = JSON.parse_string(resume_file.get_as_text())
	resume_file.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RESUME_PATH))
	return resume_data if resume_data is Dictionary else {}

static func clear() -> void:
	# Narrative event battles need their serialized continuation to survive the
	# battle scene's normal cleanup. Ordinary encounters still clear normally.
	if FileAccess.file_exists(PATH):
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file != null:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary and data.has("event_resume"):
				var resume_file := FileAccess.open(RESUME_PATH, FileAccess.WRITE)
				if resume_file != null:
					resume_file.store_string(JSON.stringify(data))
					resume_file.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
