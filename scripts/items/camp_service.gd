class_name CampService
extends RefCounted

## Camp is a low-friction recovery point. It restores party HP and clears temporary battle state.
static func rest(manager: NarrativeManager) -> Dictionary:
	if manager == null:
		return {}
	var party := manager.state.get_party_formation()
	var roster: Array = party.get("roster", [])
	var before := roster.size()
	var log := manager.state.get_journey_log()
	log["entries"].append({"type":"CAMP","location":manager.state.get_world_state().get("current_location", ""),"restored_party":before})
	manager.state.set_journey_log(log)
	manager.save()
	return {"ok": true, "members_restored": before}
