extends RefCounted

## Runtime regression for the first migrated Origin Route slices.
static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUKONG"), "Wukong start should initialize")

	var wuk01 := EventSequenceManager.get_definition("WUK-01-SEQUENCE")
	assert(wuk01 != null, "WUK-01 sequence should load")
	var runner := EventRunner.new(wuk01, manager, "ORIGIN")
	var action := runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE, "WUK-01 start: %s" % str(action))
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.END, "WUK-01 end: %s" % str(action))
	assert(runner.is_finished())

	var wuk02 := EventSequenceManager.get_definition("WUK-02-SEQUENCE")
	assert(wuk02 != null, "WUK-02 sequence should load")
	runner = EventRunner.new(wuk02, manager, "ORIGIN")
	action = runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE, "WUK-02 start: %s" % str(action))
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.BATTLE, "WUK-02 battle: %s" % str(action))
	assert(action.get("handoff", {}).get("encounter_id", "") == "WUKONG_ORIGIN_WATER_CAVE")
	var snapshot := runner.to_dict()
	var resumed := EventRunner.new(wuk02, manager, "ORIGIN")
	assert(resumed.restore(snapshot))
	action = resumed.resolve_battle(true)
	assert(action.get("kind", "") == EventRunner.DIALOGUE, "WUK-02 resume: %s" % str(action))
	action = resumed.complete_action()
	assert(action.get("kind", "") == EventRunner.END, "WUK-02 end: %s" % str(action))
	assert(resumed.is_finished())

	var origin_events := OriginEventManager.new()
	var wuk03_data := origin_events.get_event("WUK-03")
	var wuk03_definition := origin_events.get_definition("WUK-03")
	assert(not wuk03_data.is_empty(), "WUK-03 raw event should exist")
	assert(not wuk03_definition.is_empty(), "WUK-03 definition should not be empty")
	assert(EventRuntime.can_present(wuk03_definition, manager, "ORIGIN"), "WUK-03 should be presentable")

	var wuk03 := EventSequenceManager.get_definition("WUK-03-SEQUENCE")
	assert(wuk03 != null, "WUK-03 sequence should load")
	runner = EventRunner.new(wuk03, manager, "ORIGIN")
	action = runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE, "WUK-03 start: %s" % str(action))
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.CHOICE, "WUK-03 choice: %s error=%s" % [str(action), runner.get_error()])
	assert(action.get("event_id", "") == "WUK-03", "WUK-03 event id: %s" % str(action))
	action = runner.submit_choice("SEEK_FREEDOM")
	assert(action.get("kind", "") == EventRunner.END, "WUK-03 end: %s error=%s" % [str(action), runner.get_error()])
	assert(runner.is_finished())
	assert(int(manager.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
	assert(manager.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")

	return {
		"passed": true,
		"sequences_executed": 3,
		"battle_resume_verified": true,
		"origin_choice_verified": true,
	}
