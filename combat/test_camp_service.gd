extends RefCounted

## Runtime regression for the camp rest boundary.
## Camp rest records a journey-log entry and does not advance chronology.

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"))
	assert(manager.encounter_character("WUKONG"))
	manager.state.set_party_formation({
		"roster": ["TANG", "WUKONG"],
		"front_row": ["TANG"],
		"back_row": ["WUKONG"],
	})

	var before_timeline := manager.state.current_global_timeline
	var before_entries := manager.state.get_journey_log().get("entries", []).size()
	var result := CampService.rest(manager)

	assert(result.get("ok", false))
	assert(int(result.get("members_present", -1)) == 2)
	assert(manager.state.current_global_timeline == before_timeline)
	var entries := manager.state.get_journey_log().get("entries", [])
	assert(entries.size() == before_entries + 1)
	var last_entry: Dictionary = entries.back()
	assert(str(last_entry.get("type", "")) == "CAMP")
	assert(int(last_entry.get("party_present", -1)) == 2)

	return {
		"passed": true,
		"members_present": int(result.get("members_present", 0)),
		"timeline_preserved": manager.state.current_global_timeline == before_timeline,
		"log_entry_recorded": entries.size() == before_entries + 1,
	}