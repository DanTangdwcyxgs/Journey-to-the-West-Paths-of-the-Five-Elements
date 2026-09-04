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
			weaknesses[str(key).to_lower()] = bool(raw_weaknesses[key])
		var unit := Combatant.new(
			str(enemy.get("id", "enemy")).to_lower(),
			str(enemy.get("display_name", enemy.get("id", "妖怪"))),
			int(enemy.get("max_hp", 1)),
			int(enemy.get("attack", 1)),
			int(enemy.get("defense", 1)),
			int(enemy.get("speed", 1)),
			int(enemy.get("shield", 0)),
			weaknesses,
			"front"
		)
		unit.combat_modifiers = enemy.get("combat_modifiers", {}).duplicate(true)
		result.append(unit)
	return result

func choose_ai_action(enemy: Combatant, allies: Array[Combatant], turn_number: int = 1) -> CombatAction:
	if enemy == null:
		return CombatAction.new("NORMAL_ATTACK", "妖兵攻击", "strike", 18, 1, 0)
	var skills: Array = enemy.combat_modifiers.get("skills", [])
	var preferred := ""
	if enemy.hp * 100 <= enemy.max_hp * 35:
		preferred = str(enemy.combat_modifiers.get("low_hp_skill", ""))
	if turn_number % 3 == 0:
		preferred = str(enemy.combat_modifiers.get("cycle_skill", preferred))
	if preferred != "":
		for skill in skills:
			if str(skill.get("id", "")) == preferred:
				return _action_from_definition(skill)
	if not skills.is_empty():
		return _action_from_definition(skills[0])
	return CombatAction.new("NORMAL_ATTACK", "妖兵攻击", "strike", 18, 1, 0)

func _action_from_definition(skill: Dictionary) -> CombatAction:
	return CombatAction.new(
		str(skill.get("id", "NORMAL_ATTACK")),
		str(skill.get("name", "妖兵攻击")),
		str(skill.get("element", "strike")),
		int(skill.get("power", 18)),
		int(skill.get("shield_hit", 1)),
		int(skill.get("bp_cost", 0))
	)
