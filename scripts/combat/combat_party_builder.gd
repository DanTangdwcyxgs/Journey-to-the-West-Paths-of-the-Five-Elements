class_name CombatPartyBuilder
extends RefCounted

## Converts the narrative party formation into Combatant instances.
## This keeps combat construction separate from the narrative save format.

const PROFILE_PATH := "res://data/combat/party_profiles.json"
const MECHANIC_PATH := "res://data/combat/character_mechanics.json"

static func build_active_party(party: PartyManager) -> Array[Combatant]:
	var profiles := _load_profiles()
	var mechanics := _load_mechanics()
	var result: Array[Combatant] = []
	for character_id in party.get_active_order():
		var profile: Dictionary = profiles.get(character_id, {})
		if profile.is_empty():
			continue
		var mechanic: Dictionary = mechanics.get(character_id, {})
		var row := "front" if character_id in party.front_row else "back"
		result.append(_build_combatant(character_id, profile, mechanic, row))
	return result

static func _build_combatant(character_id: String, profile: Dictionary, mechanic: Dictionary, row: String) -> Combatant:
	var modifier: Dictionary = profile.get("%s_modifier" % row, {})
	var defense_value := int(round(int(profile.get("defense", 1)) * float(modifier.get("defense", 1.0))))
	var speed_value := int(round(int(profile.get("speed", 1)) * float(modifier.get("speed", 1.0))))
	var unit := Combatant.new(
		character_id.to_lower(),
		str(profile.get("display_name", character_id)),
		int(profile.get("max_hp", 1)),
		int(profile.get("attack", 1)),
		defense_value,
		speed_value,
		int(profile.get("shield", 1)),
		profile.get("weaknesses", {}).duplicate(true),
		row
	)
	unit.mechanic_max = maxi(int(mechanic.get("max", 3)), 1)
	unit.mechanic_resource = 0
	return unit

static func _load_profiles() -> Dictionary:
	return _load_json(PROFILE_PATH).get("characters", {})

static func _load_mechanics() -> Dictionary:
	return _load_json(MECHANIC_PATH).get("mechanics", {})

static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
