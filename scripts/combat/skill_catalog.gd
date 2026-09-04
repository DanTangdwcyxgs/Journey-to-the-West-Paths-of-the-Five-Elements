class_name SkillCatalog
extends RefCounted

const SKILL_PATH := "res://data/combat/skills.json"

static func get_character_skills(character_id: String) -> Array:
	var data := _load()
	var characters: Dictionary = data.get("characters", {})
	var profile: Dictionary = characters.get(character_id, {})
	var result: Array = []
	for raw in profile.get("skills", []):
		if raw is Dictionary:
			result.append(raw.duplicate(true))
	return result

static func get_skill(character_id: String, skill_id: String) -> Dictionary:
	for skill in get_character_skills(character_id):
		if str(skill.get("id", "")) == skill_id:
			return skill
	return {}

static func build_action(skill: Dictionary) -> CombatAction:
	return CombatAction.new(
		str(skill.get("id", "")),
		str(skill.get("name", skill.get("id", "Skill"))),
		str(skill.get("element", "strike")),
		int(skill.get("power", 0)),
		int(skill.get("shield_hit", 0)),
		int(skill.get("bp_cost", 0))
	)

static func _load() -> Dictionary:
	if not FileAccess.file_exists(SKILL_PATH):
		return {}
	var file := FileAccess.open(SKILL_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
