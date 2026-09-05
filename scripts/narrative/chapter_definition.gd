class_name ChapterDefinition
extends RefCounted

## Normalized chapter contract used by narrative runtimes.
## Content files stay data-driven; callers should avoid reaching into raw dictionaries.

var raw: Dictionary = {}

func _init(data: Dictionary = {}) -> void:
	raw = data.duplicate(true)

func get_id() -> String:
	return str(raw.get("id", ""))

func get_title() -> String:
	return str(raw.get("title", get_id()))

func get_owner_character() -> String:
	return str(raw.get("owner_character", raw.get("character_id", "")))

func get_chapter_type() -> String:
	return str(raw.get("chapter_type", "SHARED_JOURNEY"))

func get_timeline() -> int:
	return int(raw.get("timeline", raw.get("timeline_gate", 0)))

func get_required() -> String:
	return str(raw.get("required", ""))

func get_event_id() -> String:
	return str(raw.get("event", raw.get("event_id", "")))

func get_encounter_id() -> String:
	return str(raw.get("encounter_id", ""))

func get_next_id() -> String:
	return str(raw.get("next", ""))

func get_rewards() -> Array:
	return raw.get("rewards", []).duplicate(true)

func get_world_effects() -> Array:
	return raw.get("world_effects", []).duplicate(true)

func get_recruitments() -> Array:
	return raw.get("recruit", []).duplicate(true)

func get_prerequisites() -> Array:
	return raw.get("prerequisites", raw.get("chapter_prerequisites", [])).duplicate(true)

func get_scene_ids() -> Array:
	return raw.get("scene_ids", []).duplicate(true)

func is_origin() -> bool:
	return bool(raw.get("is_origin", get_chapter_type() == "ORIGIN"))

func is_memory() -> bool:
	return bool(raw.get("is_memory", get_chapter_type() == "MEMORY"))

func is_shared() -> bool:
	return bool(raw.get("is_shared", get_chapter_type() == "SHARED_JOURNEY"))

func is_combat() -> bool:
	return not get_encounter_id().is_empty()

func is_empty() -> bool:
	return get_id().is_empty()

func to_dict() -> Dictionary:
	return raw.duplicate(true)
