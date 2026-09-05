extends RefCounted

## Runtime regression for the first migrated Origin Route slices.
static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUKONG"))

	var wuk01 := EventSequenceManager.get_definition("WUK-01-SEQUENCE")
	assert(wuk01 != null)
	var runner := EventRunner.new(wuk01, manager, "ORIGIN")
	var action := runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE)
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.END)
	assert(runner.is_finished())

	var wuk02 := EventSequenceManager.get_definition("WUK-02-SEQUENCE")
	assert(wuk02 != null)
	runner = EventRunner.new(wuk02, manager, "ORIGIN")
	action = runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE)
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.BATTLE)
	assert(action.get("handoff", {}).get("encounter_id", "") == "WUKONG_ORIGIN_WATER_CAVE")
	var snapshot := runner.to_dict()
	var resumed := EventRunner.new(wuk02, manager, "ORIGIN")
	assert(resumed.restore(snapshot))
	action = resumed.resolve_battle(true)
	assert(action.get("kind", "") == EventRunner.DIALOGUE)
	action = resumed.complete_action()
	assert(action.get("kind", "") == EventRunner.END)
	assert(resumed.is_finished())

	var wuk03 := EventSequenceManager.get_definition("WUK-03-SEQUENCE")
	assert(wuk03 != null)
	runner = EventRunner.new(wuk03, manager, "ORIGIN")
	action = runner.start()
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.CHOICE)
	assert(action.get("event_id", "") == "WUK-03")
	action = runner.submit_choice("SEEK_FREEDOM")
	assert(action.get("kind", "") == EventRunner.END)
	assert(runner.is_finished())
	assert(int(manager.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
	assert(manager.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")

	return {
		"passed": true,
		"sequences_executed": 3,
		"battle_resume_verified": true,
		"origin_choice_verified": true,
	}
