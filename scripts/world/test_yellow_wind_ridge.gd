extends RefCounted

## Regression checks for the Yellow Wind Ridge vertical-slice progression.

static func run() -> void:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUKONG"))
	manager.state.completed_milestones.append("WUKONG_RECRUITED")
	manager.state.current_global_timeline = 120

	var ridge := YellowWindRidgeManager.new()
	assert(ridge.is_available(manager))
	var entry := ridge.get_current_stage(manager)
	assert(entry.get("id", "") == "RIDGE_ENTRY")

	ridge.complete_stage(manager, "RIDGE_ENTRY")
	assert("YELLOW_RIDGE_ENTRY" in manager.state.completed_milestones)
	assert(manager.state.current_global_timeline == 120)
	assert(ridge.get_current_stage(manager).get("id", "") == "ABANDONED_INN")

	ridge.complete_stage(manager, "ABANDONED_INN")
	ridge.complete_stage(manager, "SANDSTORM_PASS")
	assert(ridge.get_current_stage(manager).get("id", "") == "YELLOW_WIND_GATE")

	assert(BountyEncounterState.start("BOUNTY_YELLOW_FANG", "YELLOW_WIND_GATE"))
	var handoff := BountyEncounterState.get_active_record()
	assert(handoff.get("bounty_id", "") == "BOUNTY_YELLOW_FANG")
	assert(handoff.get("source_stage_id", "") == "YELLOW_WIND_GATE")
	BountyEncounterState.clear()
	assert(BountyEncounterState.get_active_record().is_empty())
