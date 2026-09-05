extends SceneTree

## Regression coverage for normalized narrative event execution.
func _initialize() -> void:
	var narrative := NarrativeManager.new()
	_assert(narrative.start_new_game("WUKONG"), "game should start")

	var event := EventDefinition.new({
		"id": "TEST-EVENT",
		"title": "测试事件",
		"text": "事件文本",
		"choices": [
			{"id":"A","label":"选择 A","effects":{"relationship_values":{"WUKONG_TANG":2},"milestones":["TEST_MILESTONE"],"world_rumors":["TEST_RUMOR"],"memory_chapters":["TEST-MEMORY"]}},
			{"id":"B","label":"选择 B"}
		]
	})
	_assert(EventRuntime.can_present(event, narrative, "SHARED"), "event should be present before choice")
	_assert(EventRuntime.selected_choice(event, narrative, "SHARED") == "", "event should have no selected choice")
	_assert(EventRuntime.apply_choice(event, narrative, "A", "SHARED"), "choice should apply")
	_assert(narrative.state.get_shared_choice("TEST-EVENT") == "A", "shared choice should persist")
	_assert(int(narrative.state.relationship_values.get("WUKONG_TANG", 0)) == 2, "relationship effect should apply")
	_assert("TEST_MILESTONE" in narrative.state.completed_milestones, "milestone should apply")
	_assert("TEST_RUMOR" in narrative.state.world_state.get("heard_rumors", []), "rumor effect should apply")
	_assert("TEST-MEMORY" in narrative.state.available_memory_chapters, "memory effect should apply")
	_assert(not EventRuntime.can_present(event, narrative, "SHARED"), "selected event should no longer be present")
	_assert(not EventRuntime.apply_choice(event, narrative, "B", "SHARED"), "event choice must be one-shot")

	var origin_event := EventDefinition.new({
		"id": "ORIGIN-EVENT",
		"choices": [{"id":"A","label":"选择 A"}]
	})
	_assert(EventRuntime.can_present(origin_event, narrative, "ORIGIN"), "origin namespace should remain independent")
	_assert(EventRuntime.apply_choice(origin_event, narrative, "A", "ORIGIN"), "origin choice should apply")
	_assert(narrative.state.get_origin_choice("ORIGIN-EVENT") == "A", "origin choice should persist separately")
	_assert(narrative.state.get_shared_choice("ORIGIN-EVENT") == "", "origin choice must not leak into shared namespace")

	print("ALL EVENT RUNTIME TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
