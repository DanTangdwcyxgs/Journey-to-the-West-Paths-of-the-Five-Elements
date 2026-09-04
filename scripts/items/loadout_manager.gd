class_name LoadoutManager
extends RefCounted

## Deterministic equipment-profile manager.
## Profiles describe tradeoffs for a planned encounter; they do not mutate combat formulas directly.

var definitions: Dictionary = {}
var equipped_profiles: Dictionary = {}

func load_definitions(payload: Dictionary) -> void:
	definitions.clear()
	for profile in payload.get("profiles", []):
		if profile is Dictionary and profile.has("id"):
			definitions[str(profile["id"])] = profile

func equip(profile_id: String) -> bool:
	if not definitions.has(profile_id):
		return false
	var profile: Dictionary = definitions[profile_id]
	var character_id := str(profile.get("character_id", ""))
	if character_id == "":
		return false
	equipped_profiles[character_id] = profile_id
	return true

func unequip_character(character_id: String) -> void:
	equipped_profiles.erase(character_id)

func get_equipped_profile(character_id: String) -> Dictionary:
	var profile_id := str(equipped_profiles.get(character_id, ""))
	if profile_id == "" or not definitions.has(profile_id):
		return {}
	return definitions[profile_id].duplicate(true)

func get_effects(character_id: String) -> Dictionary:
	return get_equipped_profile(character_id).get("effects", {})

func to_dict() -> Dictionary:
	return {"equipped_profiles": equipped_profiles.duplicate(true)}

func restore(data: Dictionary) -> void:
	equipped_profiles.clear()
	var raw = data.get("equipped_profiles", {})
	if raw is Dictionary:
		for character_id in raw.keys():
			var profile_id := str(raw[character_id])
			if definitions.has(profile_id):
				equipped_profiles[str(character_id)] = profile_id
