extends RefCounted

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"))
	var action := {
		"kind": "move",
		"map_id": "EAGLE_SORROW",
		"marker_id": "EAGLE_SORROW_EXIT",
		"position": {"x": 12, "y": 8},
	}
	var applied := WorldActionService.apply_move(manager, action)
	assert(not applied.is_empty())
	assert(str(manager.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW_EXIT")
	assert("EAGLE_SORROW_EXIT" in manager.state.get_world_state().get("visited_nodes", []))

	var wait_result := WorldActionService.complete_wait({"kind":"wait", "seconds":2.5})
	assert(is_equal_approx(float(wait_result.get("seconds", 0.0)), 2.5))

	return {
		"passed": true,
		"supports_move_commit": true,
		"supports_wait_validation": true,
	}
