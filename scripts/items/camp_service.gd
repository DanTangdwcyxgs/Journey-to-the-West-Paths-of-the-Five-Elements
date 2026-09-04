class_name CampService
extends RefCounted

## Camp records a rest stop in the journey log without advancing the main chronology.
## Actual combat HP is transient in the current prototype and is not persisted between scenes.
static func rest(manager: NarrativeManager) -> Dictionary:
	if manager == null:
		return {}
	var party := manager.state.get_party_formation()
	var roster: Array = party.get("roster", [])
	var present := roster.size()
	var log := manager.state.get_journey_log()
	log["entries"].append({"type":"CAMP","location":manager.state.get_world_state().get("current_location", ""),"party_present":present})
	manager.state.set_journey_log(log)
	manager.save()
	return {"ok": true, "members_present": present}
