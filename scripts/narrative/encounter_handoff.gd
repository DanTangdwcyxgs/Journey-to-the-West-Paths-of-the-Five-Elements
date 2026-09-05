class_name EncounterHandoff
extends RefCounted

## Neutral battle handoff contract.
## BountyEncounterState remains the persisted compatibility layer for now.

var encounter_type: String = ""
var encounter_id: String = ""
var source_stage_id: String = ""
var source_chapter_id: String = ""
var source_route_id: String = ""

func _init(data: Dictionary = {}) -> void:
	encounter_type = str(data.get("encounter_type", ""))
	encounter_id = str(data.get("encounter_id", data.get("bounty_id", "")))
	source_stage_id = str(data.get("source_stage_id", ""))
	source_chapter_id = str(data.get("source_chapter_id", ""))
	source_route_id = str(data.get("source_route_id", ""))

func is_valid() -> bool:
	return not encounter_type.is_empty() and not encounter_id.is_empty()

func is_narrative() -> bool:
	return encounter_type == "origin" or encounter_type == "shared"

func is_shared() -> bool:
	return encounter_type == "shared" and source_route_id == "SHARED_JOURNEY"

func is_origin() -> bool:
	return encounter_type == "origin" and not source_route_id.is_empty() and not source_chapter_id.is_empty()

func to_dict() -> Dictionary:
	return {
		"encounter_type": encounter_type,
		"encounter_id": encounter_id,
		"source_stage_id": source_stage_id,
		"source_chapter_id": source_chapter_id,
		"source_route_id": source_route_id,
	}
