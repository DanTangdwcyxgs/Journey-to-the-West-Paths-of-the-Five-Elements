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
	_assert(EventRuntime.can_present(event, narrative), "event should be present before choice")
	_assert(EventRuntime.apply_choice(event, narrative, "A", "SHARED"), "choice should apply")
	_assert(narrative.state.get_shared_choice("TEST-EVENT") == "A", "shared choice should persist")
	_assert(int(narrative.state.relationship_values.get("WUKONG_TANG", 0)) == 2, "relationship effect should apply")
	_assert("TEST_MILESTONE" in narrative.state.completed_milestones, "milestone should apply")
	_assert("TEST_RUMOR" in narrative.state.world_state.get("heard_rumors", []), "rumor effect should apply")
	_assert("TEST-MEMORY" in narrative.state.available_memory_chapters, "memory effect should apply")
	_assert(not EventRuntime.apply_choice(event, narrative, "B", "SHARED"), "event choice must be one-shot")

	print("ALL EVENT RUNTIME TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
