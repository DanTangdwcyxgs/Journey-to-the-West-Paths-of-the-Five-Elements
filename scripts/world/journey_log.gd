class_name JourneyLog
extends RefCounted

## Persistent journal for major battles, discoveries, and world effects.
## The journal is intentionally narrative-facing rather than a raw combat log.

var entries: Array[Dictionary] = []
var defeated_targets: Array[String] = []
var active_world_effects: Array[String] = []

func record_battle(target_id: String, target_name: String, result: String, rewards: Array = [], world_effects: Array = []) -> Dictionary:
	var entry := {
		"type": "BATTLE",
		"target_id": target_id,
		"target_name": target_name,
		"result": result,
		"rewards": rewards.duplicate(true),
		"world_effects": world_effects.duplicate(true),
	}
	entries.append(entry)
	if result == "VICTORY" and target_id not in defeated_targets:
		defeated_targets.append(target_id)
	for effect in world_effects:
		var effect_id := str(effect)
		if effect_id != "" and effect_id not in active_world_effects:
			active_world_effects.append(effect_id)
	return entry

func has_defeated(target_id: String) -> bool:
	return target_id in defeated_targets

func has_world_effect(effect_id: String) -> bool:
	return effect_id in active_world_effects

func to_dict() -> Dictionary:
	return {
		"entries": entries.duplicate(true),
		"defeated_targets": defeated_targets.duplicate(),
		"active_world_effects": active_world_effects.duplicate(),
	}

func restore(data: Dictionary) -> void:
	entries.clear()
	defeated_targets.clear()
	active_world_effects.clear()
	var raw_entries = data.get("entries", [])
	if raw_entries is Array:
		for entry in raw_entries:
			if entry is Dictionary:
				entries.append(entry.duplicate(true))
	defeated_targets = _string_array(data.get("defeated_targets", []))
	active_world_effects = _string_array(data.get("active_world_effects", []))

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	return result
