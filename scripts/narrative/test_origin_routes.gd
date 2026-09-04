extends SceneTree

## Data-driven regression coverage for all five origin-route lifecycle states.
func _initialize() -> void:
	var manager := NarrativeManager.new()
	var route_manager := manager.origin_routes
	var characters := NarrativeState.CHARACTER_IDS
	var expected_counts := {}

	for character_id in characters:
		var chapters := route_manager.get_chapters(character_id)
		_assert(chapters.size() > 0, "%s should have at least one origin chapter" % character_id)
		expected_counts[character_id] = chapters.size()
		_assert(manager.start_new_game(character_id), "%s should initialize its origin route" % character_id)
		_assert(manager.state.route_progress.get(character_id, "") == NarrativeState.ROUTE_UNLOCKED, "%s route should start unlocked" % character_id)
		_assert(manager.get_origin_status(character_id).get("current_chapter", "") == str(chapters[0].get("id", "")), "%s should point at its first chapter" % character_id)

		for index in chapters.size():
			var current := manager.get_origin_status(character_id)
			_assert(not current.get("complete", false), "%s should not be complete before its last chapter" % character_id)
			var completed := manager.complete_origin_chapter(character_id)
			_assert(not completed.is_empty(), "%s chapter %d should complete" % [character_id, index + 1])
			_assert(str(completed.get("id", "")) == str(chapters[index].get("id", "")), "%s should complete chapters in data order" % character_id)
			if index + 1 < chapters.size():
				var next_status := manager.get_origin_status(character_id)
				_assert(next_status.get("state", "") == NarrativeState.ROUTE_UNLOCKED, "%s should remain unlocked until route handoff" % character_id)
				_assert(str(next_status.get("current_chapter", "")) == str(chapters[index + 1].get("id", "")), "%s should advance to chapter %d" % [character_id, index + 2])
				_assert(str(manager.state.current_origin_chapter) == str(chapters[index + 1].get("id", "")), "%s current_origin_chapter should advance" % character_id)

		var final_status := manager.get_origin_status(character_id)
		_assert(final_status.get("complete", false), "%s should report route complete after all chapters" % character_id)
		_assert(final_status.get("state", "") == NarrativeState.ROUTE_COMPLETE, "%s should enter ROUTE_COMPLETE" % character_id)
		_assert(int(final_status.get("completed_chapters", 0)) == int(expected_counts[character_id]), "%s completion count should match data" % character_id)
		_assert(manager.state.current_origin_chapter == "", "%s current origin chapter should clear at route completion" % character_id)

	print("ALL ORIGIN ROUTE LIFECYCLE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
