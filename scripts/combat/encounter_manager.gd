class_name EncounterManager
extends RefCounted

const DATA_PATH := "res://data/combat/encounters.json"
const AI_PROFILE_PATH := "res://data/combat/enemy_ai_profiles.json"

var definitions: Dictionary = {}
var ai_profiles: Dictionary = {}

func _init() -> void:
	_load_definitions()
	_load_ai_profiles()

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

func _load_ai_profiles() -> void:
	ai_profiles.clear()
	var file := FileAccess.open(AI_PROFILE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var profiles = parsed.get("profiles", {})
	if profiles is Dictionary:
		for enemy_id in profiles.keys():
			ai_profiles[str(enemy_id).to_lower()] = str(profiles[enemy_id])

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
		var profile_key := unit.id.to_lower()
		if not unit.combat_modifiers.has("target_profile") and ai_profiles.has(profile_key):
			unit.combat_modifiers["target_profile"] = ai_profiles[profile_key]
		result.append(unit)
	return result

func choose_ai_action(enemy: Combatant, allies: Array[Combatant], turn_number: int = 1) -> CombatAction:
	if enemy == null:
		return CombatAction.new("NORMAL_ATTACK", "妖兵攻击", "strike", 18, 1, 0)
	var skills: Array = enemy.combat_modifiers.get("skills", [])
	if skills.is_empty():
		return CombatAction.new("NORMAL_ATTACK", "妖兵攻击", "strike", 18, 1, 0)
	var preferred := _preferred_skill_id(enemy, turn_number)
	if preferred != "":
		var chosen := _find_skill(skills, preferred)
		if chosen != null:
			return _action_from_definition(chosen)
	return _action_from_definition(skills[0])

func choose_ai_target(enemy: Combatant, allies: Array[Combatant], action: CombatAction) -> Combatant:
	var living: Array[Combatant] = []
	for ally in allies:
		if ally != null and ally.is_alive():
			living.append(ally)
	if living.is_empty():
		return null
	var taunted := _first_status_target(living, "aggro_turns")
	if taunted != null:
		return taunted
	if action != null:
		var element := str(action.element).to_lower()
		var weak_target := _first_weak_target(living, element)
		if weak_target != null:
			return weak_target
	var tactical := _target_by_profile(enemy, living)
	if tactical != null:
		return tactical
	return _lowest_hp_target(living)

func _preferred_skill_id(enemy: Combatant, turn_number: int) -> String:
	var config: Dictionary = enemy.combat_modifiers
	if enemy.hp * 100 <= enemy.max_hp * 35:
		var low_hp := str(config.get("low_hp_skill", ""))
		if low_hp != "":
			return low_hp
	if turn_number % 3 == 0:
		var cycle := str(config.get("cycle_skill", ""))
		if cycle != "":
			return cycle
	return ""

func _find_skill(skills: Array, skill_id: String):
	for skill in skills:
		if skill is Dictionary and str(skill.get("id", "")) == skill_id:
			return skill
	return null

func _first_weak_target(targets: Array[Combatant], element: String) -> Combatant:
	if element == "":
		return null
	for target in targets:
		if bool(target.weaknesses.get(element, false)):
			return target
	return null

func _target_by_profile(enemy: Combatant, targets: Array[Combatant]) -> Combatant:
	var profile := str(enemy.combat_modifiers.get("target_profile", "lowest_hp"))
	match profile:
		"highest_attack":
			return _highest_value_target(targets, "attack")
		"lowest_defense":
			return _lowest_value_target(targets, "defense")
		"highest_speed":
			return _highest_value_target(targets, "speed")
		"lowest_hp":
			return _lowest_hp_target(targets)
		_:
			return null

func _first_status_target(targets: Array[Combatant], property_name: String) -> Combatant:
	for target in targets:
		if int(target.get(property_name)) > 0:
			return target
	return null

func _lowest_hp_target(targets: Array[Combatant]) -> Combatant:
	var result: Combatant = targets[0]
	for target in targets:
		if target.hp < result.hp:
			result = target
	return result

func _highest_value_target(targets: Array[Combatant], property_name: String) -> Combatant:
	var result: Combatant = targets[0]
	for target in targets:
		if int(target.get(property_name)) > int(result.get(property_name)):
			result = target
	return result

func _lowest_value_target(targets: Array[Combatant], property_name: String) -> Combatant:
	var result: Combatant = targets[0]
	for target in targets:
		if int(target.get(property_name)) < int(result.get(property_name)):
			result = target
	return result

func _action_from_definition(skill: Dictionary) -> CombatAction:
	return CombatAction.new(
		str(skill.get("id", "NORMAL_ATTACK")),
		str(skill.get("name", "妖兵攻击")),
		str(skill.get("element", "strike")),
		int(skill.get("power", 18)),
		int(skill.get("shield_hit", 1)),
		int(skill.get("bp_cost", 0))
	)
