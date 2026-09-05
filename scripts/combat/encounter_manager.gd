class_name EncounterManager
extends RefCounted

const NORMAL_PATH := "res://data/combat/encounters.json"
const SHARED_PATH := "res://data/combat/shared_encounters.json"
const AI_PATH := "res://data/combat/encounter_ai.json"

var definitions: Dictionary = {}
var ai_profiles: Dictionary = {}

func _init() -> void:
	_load_definitions(NORMAL_PATH)
	_load_definitions(SHARED_PATH)
	_load_ai_profiles()

func _load_definitions(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return
	var raw: Variant = parsed.get("encounters", {})
	if raw is not Dictionary:
		return
	for key in raw.keys():
		if raw[key] is Dictionary:
			var data: Dictionary = raw[key].duplicate(true)
			if not data.has("id"):
				data["id"] = str(key)
			definitions[str(key)] = data

func _load_ai_profiles() -> void:
	var file := FileAccess.open(AI_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var raw: Variant = parsed.get("profiles", {})
		if raw is Dictionary:
			ai_profiles = raw.duplicate(true)

func get_definition(encounter_id: String) -> Dictionary:
	return definitions.get(encounter_id, {}).duplicate(true)

func has_encounter(encounter_id: String) -> bool:
	return not get_definition(encounter_id).is_empty()

func build_enemies(encounter_id: String) -> Array[Combatant]:
	var definition := get_definition(encounter_id)
	var result: Array[Combatant] = []
	if definition.is_empty():
		return result
	for enemy in definition.get("enemies", []):
		if not enemy is Dictionary:
			continue
		var unit := Combatant.from_definition(enemy)
		var profile_key := unit.id.to_lower()
		var profile: Dictionary = ai_profiles.get(profile_key, {})
		if not unit.combat_modifiers.has("target_profile") and profile.has("target_profile"):
			unit.combat_modifiers["target_profile"] = str(profile.get("target_profile", "lowest_hp"))
		if profile.has("skill_effects"):
			unit.combat_modifiers["skill_effects"] = profile.get("skill_effects", {}).duplicate(true)
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
		var chosen: Variant = _find_skill(skills, preferred)
		if chosen != null and chosen is Dictionary:
			return _action_from_definition(enemy, chosen)
	return _action_from_definition(enemy, skills[0])

func choose_ai_target(enemy: Combatant, allies: Array[Combatant], action: CombatAction) -> Combatant:
	var living: Array[Combatant] = []
	for ally in allies:
		if ally != null and ally.is_alive():
			living.append(ally)
	if living.is_empty():
		return null
	var scored := _score_targets(enemy, living, action)
	if scored.is_empty():
		return null
	return scored[0]["target"]

func _score_targets(enemy: Combatant, targets: Array[Combatant], action: CombatAction) -> Array:
	var ranked: Array = []
	var element := str(action.element).to_lower() if action != null else ""
	var profile := str(enemy.combat_modifiers.get("target_profile", "lowest_hp"))
	for index in targets.size():
		var target: Combatant = targets[index]
		var score := 0
		if target.aggro_turns > 0:
			score += 1000
		if element != "" and bool(target.weaknesses.get(element, false)):
			score += 600
		score += _profile_score(profile, target)
		score += maxi(0, 100 - int((float(target.hp) / maxi(target.max_hp, 1)) * 100.0))
		score -= index
		ranked.append({"target": target, "score": score})
	ranked.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	return ranked

func _profile_score(profile: String, target: Combatant) -> int:
	match profile:
		"highest_attack":
			return target.attack
		"lowest_defense":
			return maxi(0, 100 - target.defense * 5)
		"highest_speed":
			return target.speed
		"lowest_hp":
			return maxi(0, 100 - int((float(target.hp) / maxi(target.max_hp, 1)) * 100.0))
		_:
			return 0

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

func _action_from_definition(enemy: Combatant, skill: Dictionary) -> CombatAction:
	var effects: Dictionary = {}
	var skill_id := str(skill.get("id", ""))
	var skill_effects: Dictionary = enemy.combat_modifiers.get("skill_effects", {})
	if skill_effects.has(skill_id) and skill_effects[skill_id] is Dictionary:
		effects = skill_effects[skill_id].duplicate(true)
	for key in ["effect", "effect_duration", "effect_value", "shield_bonus", "shield_damage_bonus"]:
		if skill.has(key):
			effects[key] = skill[key]
	return CombatAction.new(
		skill_id if skill_id != "" else "NORMAL_ATTACK",
		str(skill.get("name", "妖兵攻击")),
		str(skill.get("element", "strike")),
		int(skill.get("power", 18)),
		int(skill.get("shield_hit", 1)),
		int(skill.get("bp_cost", 0)),
		effects
	)
