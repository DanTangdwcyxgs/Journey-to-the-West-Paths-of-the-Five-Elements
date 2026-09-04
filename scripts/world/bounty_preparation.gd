class_name BountyPreparation
extends RefCounted

## Turns bounty intelligence + current loadouts into a readable preparation report.
## It only recommends; it never mutates the player's equipment.

static func build_report(bounty: Dictionary, loadout_manager: LoadoutManager) -> Dictionary:
	var weaknesses: Array = bounty.get("weaknesses", [])
	var recommended_profiles: Array[String] = []
	for profile_id in loadout_manager.definitions.keys():
		var profile: Dictionary = loadout_manager.definitions[profile_id]
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
	var tags: Array = profile.get("tags", [])
	for weakness in weaknesses:
		if str(weakness) in tags:
			return true
	return false
