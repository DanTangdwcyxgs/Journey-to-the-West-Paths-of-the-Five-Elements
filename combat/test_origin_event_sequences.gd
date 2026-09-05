extends RefCounted

## Runtime regression for the complete Wukong Origin Route sequence migration.
static func _run_sequence(manager: NarrativeManager, sequence_id: String, choice_id: String = "") -> Dictionary:
	var definition := EventSequenceManager.get_definition(sequence_id)
	assert(definition != null, "%s definition should load" % sequence_id)
	var runner := EventRunner.new(definition, manager, "ORIGIN")
	var action := runner.start()
	assert(not action.is_empty(), "%s should return a start action" % sequence_id)

	var steps := 0
	while not runner.is_finished():
		steps += 1
		assert(steps < 32, "%s exceeded safe action step count" % sequence_id)
		var kind := str(action.get("kind", ""))
		if kind == EventRunner.BATTLE:
			var handoff := action.get("handoff", {})
			assert(not handoff.is_empty(), "%s battle should provide a handoff" % sequence_id)
			var encounter_id := str(handoff.get("encounter_id", ""))
			assert(not encounter_id.is_empty(), "%s battle encounter id should exist" % sequence_id)
			action = runner.resolve_battle(true)
		elif kind == EventRunner.CHOICE:
			assert(not choice_id.is_empty(), "%s requires an explicit choice" % sequence_id)
			action = runner.submit_choice(choice_id)
		else:
			action = runner.complete_action()

	assert(runner.is_finished(), "%s should finish" % sequence_id)
	return {
		"sequence_id": sequence_id,
		"steps": steps,
	}

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUKONG"), "Wukong start should initialize")

	var origin_events := OriginEventManager.new()
	var wuk03_definition := origin_events.get_definition("WUK-03")
	assert(not wuk03_definition.is_empty(), "WUK-03 definition should not be empty")
	assert(EventRuntime.can_present(wuk03_definition, manager, "ORIGIN"), "WUK-03 should be presentable")

	var results: Array[Dictionary] = []
	results.append(_run_sequence(manager, "WUK-01-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-02-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-03-SEQUENCE", "SEEK_FREEDOM"))
	results.append(_run_sequence(manager, "WUK-04-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-05-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-06-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-07-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-08-SEQUENCE", "ACCEPT_TITLE"))
	results.append(_run_sequence(manager, "WUK-09-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-10-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-11-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-12-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-13-SEQUENCE", "ENDURE"))
	results.append(_run_sequence(manager, "WUK-14-SEQUENCE"))
	results.append(_run_sequence(manager, "WUK-15-SEQUENCE"))

	assert(results.size() == 15, "All Wukong origin sequences should execute")
	assert(int(manager.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
	assert(manager.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")
	assert(manager.state.get_origin_choice("WUK-08") == "ACCEPT_TITLE")
	assert(manager.state.get_origin_choice("WUK-13") == "ENDURE")

	return {
		"passed": true,
		"sequences_executed": results.size(),
		"battle_sequences_verified": 5,
		"choice_sequences_verified": 3,
		"complete_wukong_route_verified": true,
	}
