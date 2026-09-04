extends SceneTree

## Regression coverage for all five origin-route -> shared-journey handoffs.
func _initialize() -> void:
	var expected_shared := {
		"WUKONG":"SHARED-01-FIVE-ELEMENTS",
		"TANG":"SHARED-01-FIVE-ELEMENTS",
		"LONGMA":"SHARED-03-EAGLE-SORROW",
		"BAJIE":"SHARED-05-GAOJIAZHUANG",
		"WUJING":"SHARED-07-FLOWING-SANDS",
	}
	var expected_timeline := {
		"WUKONG":100,
		"TANG":100,
		"LONGMA":110,
		"BAJIE":130,
		"WUJING":150,
	}
	var expected_roster := {
		"WUKONG":2,
		"TANG":2,
		"LONGMA":3,
		"BAJIE":4,
		"WUJING":5,
	}

	for character_id in NarrativeState.CHARACTER_IDS:
		var manager := NarrativeManager.new()
		_assert(manager.start_new_game(character_id), "%s should start" % character_id)
		var total := manager.origin_routes.get_chapters(character_id).size()
		for _i in total:
			var completed := manager.complete_origin_chapter(character_id)
			_assert(not completed.is_empty(), "%s origin chapter should complete" % character_id)
		_assert(manager.handoff_origin_to_shared(character_id), "%s should hand off" % character_id)
		_assert(manager.state.route_progress.get(character_id, "") == NarrativeState.ROUTE_COMPLETE, "%s route should be complete" % character_id)
		_assert(manager.state.current_shared_chapter == expected_shared[character_id], "%s shared entry should match canon" % character_id)
		_assert(manager.state.current_global_timeline == expected_timeline[character_id], "%s handoff timeline should match canon" % character_id)
		_assert(manager.state.recruited_characters.size() == expected_roster[character_id], "%s roster size should match handoff" % character_id)
		_assert(manager.state.recruited_characters[0] == "TANG", "%s handoff should include Tang first" % character_id)
		_assert("WUKONG" in manager.state.recruited_characters, "%s handoff should contain Wukong" % character_id)
		if expected_roster[character_id] >= 3:
			_assert(manager.state.recruited_characters.has("LONGMA"), "%s handoff should contain Longma" % character_id)
		if expected_roster[character_id] >= 4:
			_assert(manager.state.recruited_characters.has("BAJIE"), "%s handoff should contain Bajie" % character_id)
		if expected_roster[character_id] == 5:
			_assert(manager.state.recruited_characters.has("WUJING"), "%s handoff should contain Wujing" % character_id)

	print("ALL ORIGIN HANDOFF TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
