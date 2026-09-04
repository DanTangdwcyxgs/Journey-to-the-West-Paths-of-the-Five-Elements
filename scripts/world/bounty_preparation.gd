class_name BountyPreparation
extends RefCounted

## Turns bounty intelligence + current loadouts into a readable preparation report.
## It only recommends; it never mutates the player's equipment.

static func build_report(bounty: Dictionary, loadout_manager: LoadoutManager) -> Dictionary:
	var weaknesses: Array = bounty.get("weaknesses", [])
	var recommended_profiles: Array[String] = []
	for profile_id in loadout_manager.definitions.keys():
		var profile: Dictionary = loadout_manager.definitions[profile_id]
		var effects: Dictionary = profile.get("effects", {})
		if _matches_weaknesses(profile, weaknesses):
			recommended_profiles.append(str(profile_id))

	return {
		"bounty_id": str(bounty.get("id", "")),
		"recommended_level": int(bounty.get("recommended_level", 0)),
		"weaknesses": weaknesses.duplicate(),
		"can_retreat": bool(bounty.get("can_retreat", true)),
		"recommended_profiles": recommended_profiles,
		"current_loadouts": loadout_manager.equipped_profiles.duplicate(true),
	}

static func _matches_weaknesses(profile: Dictionary, weaknesses: Array) -> bool:
	var profile_name := str(profile.get("name", ""))
	var purpose := str(profile.get("purpose", ""))
	for weakness in weaknesses:
		var token := str(weakness).to_lower()
		if profile_name.to_lower().contains(token) or purpose.to_lower().contains(token):
			return true
	return false
