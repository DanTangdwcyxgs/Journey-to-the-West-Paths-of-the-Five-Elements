class_name EncounterManager
extends RefCounted

const DATA_PATH := "res://data/combat/encounters.json"

var definitions: Dictionary = {}

func _init() -> void:
	_load_definitions()

func _load_definitions() -> void:
	definitions.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	for encounter in parsed.get("encounters", []):
		if encounter is Dictionary and encounter.has("id"):
			definitions[str(encounter.get("id"))] = encounter.duplicate(true)

func get_definition(encounter_id: String) -> Dictionary:
	return definitions.get(encounter_id, {}).duplicate(true)

func build_enemies(encounter_id: String) -> Array[Combatant]:
	var result: Array[Combatant] = []
	var definition := get_definition(encounter_id)
	for enemy in definition.get("enemies", []):
		if not enemy is Dictionary:
			continue
		var raw_weaknesses: Dictionary = enemy.get("weaknesses", {})
		var weaknesses: Dictionary = {}
		for key in raw_weaknesses.keys():
			weaknesses[str(key)] = bool(raw_weaknesses[key])
		result.append(Combatant.new(
			str(enemy.get("id", "enemy")).to_lower(),
			str(enemy.get("display_name", enemy.get("id", "妖怪"))),
			int(enemy.get("max_hp", 1)),
			int(enemy.get("attack", 1)),
			int(enemy.get("defense", 1)),
			int(enemy.get("speed", 1)),
			int(enemy.get("shield", 0)),
			weaknesses,
			"front"
		))
	return result
